require 'andand'
require 'pp'

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..'))
require 'db/init'
require 'models/repository'
require 'models/doi_mapping'

module Harvest

  class Repositories < Thor

    desc 'list', 'list registered repositories'
    def list
      Repository.all.each do |r|
        puts "#{r.id} - #{r.base_url}: #{r.name || ''}"
      end
    end

    desc 'add BASE_URL', 'register a new repository'
    def add(base_url)
      if Repository.find(base_url: base_url).nil?
        say_status "add", base_url
        r = Repository.create(base_url: base_url)

        say_status "identify", base_url
        r.identify!
        r.save
      end
    end

    desc 'rm BASE_URL', 'remove a repository'
    def rm(base_url)
      repository = Repository.find(base_url: base_url)
      repository.doi_mappings.each {|m| m.destroy}
      repository.destroy
    end

  end

  class Dois < Thor

    desc 'harvest', 'harvest DOIs'
    option :limit, type: :numeric
    def harvest
      Repository.all.each do |r|
        count = 0
        list_opts = {}
        if options[:limit]
          list_opts[:limit] = options[:limit].to_i
        end
        mappings = r.list_records(options)
        mappings.each do |mapping|
          begin
            mapping.save
            say_status "doi", "'#{mapping.doi}' => '#{mapping.url}'", :yellow
          rescue Exception => e
            pp e
            say_status "invalid", "'#{mapping.doi}' => '#{mapping.url}'", :red
          end
        end
        say_status "found", "#{mappings.length} DOIs", :green
      end
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

end
