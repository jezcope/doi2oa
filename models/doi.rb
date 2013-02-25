require 'sequel'

class Doi < Sequel::Model
  plugin :validation_helpers

  many_to_one :repository

  def validate
    super

    validates_presence [:repository, :doi]
  end

  def self.new_from_oai_record(repository, record)
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
        return Doi.new(repository: repository,
                       doi: dois.first, url: others.first)
      end
    end
  end

end
