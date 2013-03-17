require 'beaneater'
require 'json'
require 'andand'
require 'pp'
require 'logger'

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..'))
require 'db/init'
require 'models/repository'
require 'models/doi_mapping'

module Harvest

  module Helpers

    def harvest_dois(repository, logger, job = nil)
      logger.info "Harvesting from #{repository.base_url}" 
      say_status "harvest", "#{repository.name} (#{repository.base_url})"
      count = 0
      list_opts = {save: false, full: false}

      if options[:limit]
        list_opts[:limit] = options[:limit].to_i
      end
      
      response = repository.list_records(list_opts)
      until response.resumption_token.nil?
        response.mappings.each do |mapping|
          begin
            mapping.save
            say_status "doi", "'#{mapping.doi}' => '#{mapping.url}'", :yellow
          rescue Sequel::ValidationFailed => e
            logger.warn "Invalid DOI: <#{mapping.doi}> => <#{mapping.url}>"
            say_status "invalid", "'#{mapping.doi}' => '#{mapping.url}'", :red
          end
        end
        
        logger.debug "Got #{response.mappings.length} DOIs for #{repository.base_url}"
        count += response.mappings.length

        unless job.nil?
          if job.stats.time_left == 0
            # We've already timed out and we don't want to run again for now
            job.bury
            logger.info "Job #{job.id} timed out: #{repository.base_url}"
            return
          end
          #logger.debug "Job #{job.id} has #{job.stats.time_left} seconds left"
          job.touch
        end

        list_opts[:resumption_token] = response.resumption_token
        response = repository.list_records(list_opts)
      end
      
      logger.info "Got #{count} DOIs total for #{repository.base_url}" 
      say_status "found", "#{count} DOIs", :green
    end

  end

  class NonExistentRepository < ArgumentError
  end

  class Repositories < Thor

    desc 'list', 'list registered repositories'
    def list
      Repository.all.each do |r|
        puts "#{r.id} - #{r.base_url}: #{r.name || ''}"
      end
    end

    desc 'add BASE_URL', 'register a new repository'
    option :identify, default: true
    def add(base_url)
      if Repository.find(base_url: base_url).nil?
        say_status "add", base_url
        r = Repository.create(base_url: base_url)

        if options[:identify]
          say_status "identify", base_url
          begin
            r.identify!
          rescue
            say_status "error", "identifying #{base_url}", :red
          end
        end

        begin
          r.save
        rescue
          say_status "error", "saving #{base_url}", :red
        end
      end
    end

    desc 'rm BASE_URL', 'remove a repository'
    def rm(base_url)
      repository = Repository.find(base_url: base_url)
      if repository.nil?
        say_status "not found", "base_url: #{base_url}", :red
      else
        repository.doi_mappings.each {|m| m.destroy}
        repository.destroy
        say_status "deleted", "base_url: #{base_url}"
      end
    end

  end

  class Dois < Thor
    include Harvest::Helpers

    desc 'harvest_all', 'harvest DOIs'
    option :limit, type: :numeric
    def harvest_all
      logger = Logger.new('harvest.log')
      logger.formatter = Logger::Formatter.new
      logger.progname = 'harvest:dois:harvest_all'
      Repository.all.each do |r|
        harvest_dois(r, logger)
      end
    end

    desc 'harvest ID', 'harvest DOIs'
    option :limit, type: :numeric
    def harvest(id)
      logger = Logger.new('harvest.log')
      logger.formatter = Logger::Formatter.new
      logger.progname = 'harvest:dois:harvest'
      r = Repository.find(id: id)
      harvest_dois(r, logger)
    end

    desc 'count', 'print number of DOI records in database'
    def count
      say_status "count", "#{DoiMapping.count} DOI records"
    end

    desc 'clear', 'clear DOI records from database'
    def clear
      say_status "delete", "#{DoiMapping.count} DOI records", :yellow
      DoiMapping.delete
      invoke :count
    end

  end

  class Queue < Thor
    include Harvest::Helpers

    desc 'process [TUBE_NAME]', 'process jobs from beanstalkd'
    def process(tube_name = 'doi2oa')
      logger = Logger.new('harvest.log')
      logger.formatter = Logger::Formatter.new
      logger.progname = 'harvest:queue:process'
      pool = Beaneater::Pool.new(%w{localhost:11300})
      
      pool.jobs.register(tube_name) do |job|
        begin
          logger.debug "Claimed job #{job.id}: #{job.body}"
          job_info = JSON::load(job.body)
          r = Repository.find(id: job_info['repository_id'].to_i)

          if r.nil?
            logger.warn "Tried to harvest from non-existent repository #{job_info['repository_id']}"
            raise NonExistentRepository.new
          end

          logger.info "Begin harvesting from #{r.base_url}"

          harvest_dois(r, logger, job)
          
          logger.info "Finished harvesting from #{r.base_url}"
        rescue Exception => e
          logger.error "Error: #{e.inspect} on job #{job.inspect}"
          raise e
        end
      end

      logger.info "Ready to process jobs"

      begin
        pool.jobs.process!
      rescue Interrupt
        puts "Received ^C: exiting..."
      end
    end

    desc 'add_all [TUBE_NAME]', 'enqueue all repositories for harvesting'
    def add_all(tube_name = 'doi2oa')
      logger = Logger.new('harvest.log')
      logger.formatter = Logger::Formatter.new
      logger.progname = 'harvest:queue:add_all'
      pool = Beaneater::Pool.new(%w{localhost:11300})
      tube = pool.tubes[tube_name]

      Repository.all.each do |r|
        job = {command: :harvest, repository_id: r.id}
        tube.put job.to_json
        logger.info "Enqueued #{r.base_url} in tube '#{tube_name}' for harvesting"
        logger.debug "Job info: #{job.to_json}"
      end
    end

    desc 'add ID [TUBE_NAME]', 'enqueue a repository for harvesting'
    def add(id, tube_name = 'doi2oa')
      logger = Logger.new('harvest.log')
      logger.formatter = Logger::Formatter.new
      logger.progname = 'harvest:queue:add'
      pool = Beaneater::Pool.new(%w{localhost:11300})
      tube = pool.tubes[tube_name]

      r = Repository.find(id: id)
      job = {command: :harvest, repository_id: id}
      tube.put job.to_json
      logger.info "Enqueued #{r.base_url} in tube '#{tube_name}' for harvesting"
      logger.debug "Job info: #{job.to_json}"
    end

    desc 'delete_buried [TUBE_NAME]', 'delete buried jobs'
    def delete_buried(tube_name = 'doi2oa')
      logger = Logger.new('harvest.log')
      logger.formatter = Logger::Formatter.new
      logger.progname = 'harvest:queue:delete_buried'
      pool = Beaneater::Pool.new(%w{localhost:11300})
      tube = pool.tubes[tube_name]

      job = tube.peek(:buried)
      while job
        logger.info "Deleting buried job #{job.id} #{job.body}"
        say_status "delete", "Buried job #{job.id} #{job.body}"
        job.delete
        job = tube.peek(:buried)
      end
    end

    desc 'delete_ready [TUBE_NAME]', 'delete waiting jobs'
    def delete_ready(tube_name = 'doi2oa')
      logger = Logger.new('harvest.log')
      logger.formatter = Logger::Formatter.new
      logger.progname = 'harvest:queue:delete_ready'
      pool = Beaneater::Pool.new(%w{localhost:11300})
      tube = pool.tubes[tube_name]

      job = tube.peek(:ready)
      while job
        logger.info "Deleting waiting job #{job.id} #{job.body}"
        say_status "delete", "Waiting job #{job.id} #{job.body}"
        job.delete
        job = tube.peek(:ready)
      end
    end

  end

end
