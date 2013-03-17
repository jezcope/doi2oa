require 'sequel'
require 'andand'

class DoiMapping < Sequel::Model
  plugin :validation_helpers

  many_to_one :repository
  
  NAMESPACES = %w{
    dc:http://purl.org/dc/elements/1.1/
    oai:http://www.openarchives.org/OAI/2.0/
  }

  def validate
    super

    validates_presence [:repository, :doi]
    validates_format    %r{^https?://([\da-z\.-]+)\.([a-z\.]{2,6})([/\w \.-]*)*/?$|^$}, :url,
      message: "invalid URL: '#{url}'"
    validates_format    %r{^10\.[0-9A-Za-z]+(?:\.[0-9A-Za-z]+)?/}, :doi,
      message: "invalid DOI: '#{doi}'"
  end

  def doi=(value)
    # sanitise DOI by removing common errors
    super(value.andand.sub(/^\s*(doi)?:?\s*/, '').strip)
  end
  
  def self.find_or_new(*args)
    find(*args) || new(*args)
  end

  def self.new_or_update_from_oai(repository, record)
    metadata = record.metadata
    return if metadata.nil?

    doi_candidates, url_candidates = [], []

    # Try <dc:identifier> elements
    identifiers = metadata.find('.//dc:identifier', NAMESPACES)
    unless identifiers.nil?
      identifiers.each do |id|
        extract_doi_or_url id.inner_xml, doi_candidates, url_candidates
      end
    end

    # Try <dc:relation> elements
    relations = metadata.find('.//dc:relation', NAMESPACES)
    unless relations.nil?
      relations.each do |rel|
        extract_doi_or_url rel.inner_xml, doi_candidates, url_candidates
      end
    end

    url_candidates.sort! {|url| url.length}

    if doi_candidates.length > 0
      mapping = find_or_new(repository: repository, doi: doi_candidates.first)
      mapping.url = url_candidates.first
      return mapping
    end
  end

  def self.resolve(doi)
    find(doi: doi).andand.url
  end

  private

  def self.extract_doi_or_url(content, dois, urls)
    content = content.strip
    if content.start_with? 'http://dx.doi.org/'
      dois << content[18..-1]
    elsif content.start_with? '10.'
      dois << content
    elsif content =~ %r{^https?://}
      urls << content
    end
  end

end
