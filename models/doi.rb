require 'sequel'
require 'andand'

class Doi < Sequel::Model
  plugin :validation_helpers

  many_to_one :repository

  def validate
    super

    validates_presence [:repository, :doi]
    validates_format    %r{^https?://([\da-z\.-]+)\.([a-z\.]{2,6})([/\w \.-]*)*/?$|^$}, :url,
      message: "invalid URL: '#{url}'"
    validates_format    %r{^10\.[0-9A-Za-z]+(?:\.[0-9A-Za-z]+)?/}, :doi,
      message: "invalid DOI: '#{doi}'"
  end

  def doi=(value)
    # sanitise DOI by removing leading/trailing space
    super(value.andand.strip)
  end
  
  def self.find_or_new(*args)
    self.find(*args) || self.new(*args)
  end

  def self.new_or_update_from_oai(repository, record)
    # Both the DOI and the OA URL are reported as relations in the DC schema
    relations = record.metadata.andand.find('.//dc:relation', 'dc:http://purl.org/dc/elements/1.1/')
    
    return if relations.nil?

    relations = relations.map {|rel| rel.inner_xml}
    dois, others = relations.partition do |rel|
      rel.start_with? 'http://dx.doi.org/'
    end

    if dois.length > 0
      doi_record = Doi.find_or_new(repository: repository, doi: dois.first[18..-1])
      doi_record.url = others.first
      return doi_record
    end
  end

  def self.resolve(doi)
    find(doi: doi).andand.url
  end
end
