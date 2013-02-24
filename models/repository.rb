require 'sequel'
require 'oai'

class Repository < Sequel::Model
  plugin :validation_helpers

  one_to_many :dois
  
  def validate
    super

    validates_presence  :base_url
    validates_unique    :base_url
    validates_format    %r{^https?://([\da-z\.-]+)\.([a-z\.]{2,6})([\/\w \.-]*)*\/?$}, :base_url
  end

  def fetch_info_from_server
    client = OAI::Client.new base_url, parser: 'libxml'
    response = client.identify

    set(name: response.repository_name,
        admin_email: response.admin_email,
        earliest_datestamp: response.earliest_datestamp)
  end

end
