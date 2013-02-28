require 'andand'
require 'pp'

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..'))
require 'db/init'
require 'models/repository'
require 'models/doi'

module Harvest

  class Repositories < Thor

    desc 'list', 'list registered repositories'
    def list
      Repository.all.each do |r|
        puts "#{r.base_url}: #{r.name || ''}"
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

  end

  class Dois < Thor

    desc 'harvest', 'harvest DOIs'
    def harvest
      Repository.all.each do |r|
        count = 0
        dois, token = r.list_records
        until token.nil?
          count += dois.length
          dois.each do |doi|
            if doi.valid?
              doi.save
              say_status "doi", "#{doi.doi} => #{doi.url}", :yellow
            else
              say_status "invalid", "#{doi.doi} => #{doi.url}", :red
            end
          end

          say_status "found", "#{count} DOIs so far", :green

          dois, token = r.list_records(token)
        end
      end
    end

  end

end
