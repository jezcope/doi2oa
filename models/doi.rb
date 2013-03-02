require 'sequel'
require 'andand'

class Doi < Sequel::Model
  plugin :validation_helpers

  many_to_one :repository

  def validate
    super

    validates_presence [:repository, :doi]
    validates_format    %r{^https?://([\da-z\.-]+)\.([a-z\.]{2,6})([\/\w \.-]*)*\/?$}, :url
    validates_format    %r{^10\.[0-9A-Za-z]+(?:\.[0-9A-Za-z]+)?/}, :doi
  end

  def self.create_or_update_from_oai(repository, record)
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
        doi_record = Doi.find_or_create(repository: repository, doi: dois.first)
        doi_record.url = others.first
        return doi_record
      end
    end
  end

  def self.resolve(doi)
    find(doi: doi).andand.url
  end
end
