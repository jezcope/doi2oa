require 'spec_helper'

require 'xml'

require 'models/doi'
require 'models/repository'

describe Doi, :models => true do

  before(:all) do
    @record = OAI::Record.new(
      XML::Document.file('spec/fixtures/record.xml').root)
    @repository = create(:repository)
  end

  it "should be valid with valid parameters" do
    build(:doi).should be_valid
  end

  it "should require a repository" do
    build(:doi, repository: nil).should_not be_valid
  end

  it "should require a DOI" do
    expect { create(:doi, doi: nil) }.to raise_error
  end

  it "should construct from an OAI-PMH record" do
    doi = Doi.new_from_oai_record(@repository, @record)

    doi.repository.should == @repository
    doi.doi.should == "10.1016/j.laa.2007.11.013"
    doi.url.should == "http://opus.bath.ac.uk/167/"
    doi.should be_valid
  end

end
