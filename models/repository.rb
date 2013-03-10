require 'sequel'
require 'andand'
require 'oai'

require_relative 'doi_mapping'

class Repository < Sequel::Model
  plugin :validation_helpers

  one_to_many :doi_mappings
  
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
    limit = options[:limit] || Float::INFINITY
    save  = options[:save]

    client = OAI::Client.new base_url, parser: 'libxml'
    response = client.list_records

    mappings = []
    response.full.each do |record| 
      doi_mapping = DoiMapping.new_or_update_from_oai self, record
      unless doi_mapping.nil?
        doi_mapping.save if save
        mappings << doi_mapping
        return mappings if mappings.length >= limit
      end
    end

    mappings
  end

end
