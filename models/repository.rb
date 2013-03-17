require 'sequel'
require 'andand'
require 'oai'

require_relative 'doi_mapping'

class Repository < Sequel::Model
  plugin :validation_helpers

  one_to_many :doi_mappings

  class ListRecordsResponse

    def initialize(mappings, resumption_token = nil)
      @mappings = mappings
      @resumption_token = resumption_token
    end

    attr_reader :mappings
    attr_reader :resumption_token

  end
  
  def validate
    super

    validates_presence  :base_url
    validates_unique    :base_url
    validates_format    %r{^https?://([\da-z\.-]+)\.([a-z\.]{2,6})([\/\w \.-]*)*\/?$}, :base_url
  end

  def identify!
    client = OAI::Client.new base_url, parser: 'libxml'
    response = client.identify

    set(name: response.repository_name,
        admin_email: response.admin_email,
        earliest_datestamp: response.earliest_datestamp)
  end

  def list_records(options = {})
    limit = options.fetch(:limit, Float::INFINITY)
    save  = options.fetch(:save,  false)
    full  = options.fetch(:full,  false)

    list_opts = {}
    list_opts[:resumption_token] = options[:resumption_token] if options.has_key?(:resumption_token)

    client = OAI::Client.new base_url, parser: 'libxml'
    response = client.list_records(list_opts)
    resumption_token = response.resumption_token

    mappings = []

    response = response.full if full
    
    response.each do |record| 
      doi_mapping = DoiMapping.new_or_update_from_oai self, record
      unless doi_mapping.nil?
        doi_mapping.save if save
        mappings << doi_mapping
        if mappings.length >= limit
          return ListRecordsResponse.new(mappings) 
        end
      end
    end

    ListRecordsResponse.new(mappings, full ? nil : resumption_token)
  end

end
