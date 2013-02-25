require 'oai'
require 'andand'
require 'pp'

class Oai < Thor

  desc 'identify [ENDPOINT]', 'identify a repository'
  def identify(endpoint='http://opus.bath.ac.uk/cgi/oai2')
    client = OAI::Client.new endpoint, parser: 'libxml'
    response = client.identify
    puts "Repository name: #{response.repository_name}"
    puts "Admin email: #{response.admin_email}"
    puts "Base URL: #{response.base_url}"
    puts "Compression: #{response.compression}"
    puts "Deleted record: #{response.deleted_record}"
    puts "Earliest datestamp: #{response.earliest_datestamp}"
    puts "Granularity: #{response.granularity}"
    puts "Protocol: #{response.protocol}"
  end

  desc 'list_records [ENDPOINT]', 'list records in a repository'
  option :resumption_token, aliases: %w(-r)
  def list_records(endpoint='http://opus.bath.ac.uk/cgi/oai2')
    client = OAI::Client.new endpoint, parser: 'libxml'
    opts = {}
    if options.resumption_token
      opts[:resumption_token] = options.resumption_token
    end
    response = client.list_records(opts)

    for record in response
      unless record.metadata.nil?
        puts record.metadata.find('.//dc:title', 'dc:http://purl.org/dc/elements/1.1/').first.inner_xml
      end
    end

    puts "------------------------------------------------------------------------------"
    puts "Resumption token: #{response.resumption_token}"
  end

  desc 'list_dois [ENDPOINT]', 'list a batch of DOIs and OA URLs'
  option :resumption_token, aliases: %w(-r)
  def list_dois(endpoint='http://opus.bath.ac.uk/cgi/oai2')
    client = OAI::Client.new endpoint, parser: 'libxml'
    opts = {}
    if options.resumption_token
      opts[:resumption_token] = options.resumption_token
    end
    response = client.list_records(opts)
    
    doi_count = 0

    for record in response
      relations = record.metadata.andand.find('.//dc:relation', 'dc:http://purl.org/dc/elements/1.1/')
      unless relations.nil?
        dois = []
        others = []
        relations.each do |rel|
          if result = /^https?:\/\/dx\.doi\.org\/(.*)$/.match(rel.inner_xml)
            dois << result[1]
          else
            others << rel.inner_xml
          end
        end
        if dois.length > 0
          puts dois.first
          others.each { |x| puts " => #{x}" }
          doi_count += 1
        end
      end
    end

    puts "------------------------------------------------------------------------------"
    puts "Found #{doi_count} DOIs"
    puts "------------------------------------------------------------------------------"
    puts "Resumption token: #{response.resumption_token}"
  end

end
