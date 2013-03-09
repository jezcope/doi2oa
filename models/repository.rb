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

  def list_records(resumption_token = nil)
    client = OAI::Client.new base_url, parser: 'libxml'
    opts = {}
    opts[:resumption_token] = resumption_token unless resumption_token.nil?
    response = client.list_records(opts)

    dois = []
    response.each do |record| 
      doi_mapping = DoiMapping.new_or_update_from_oai self, record
      dois << doi_mapping unless doi_mapping.nil?
    end

    [dois, response.resumption_token]
  end

end
