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

  it "should require DOI to be in the right format" do
    build(:doi, doi: "not a valid doi").should_not be_valid
    build(:doi, doi: "23.1234/something").should_not be_valid
    build(:doi, doi: "23.1*234/something").should_not be_valid
    build(:doi, doi: "10.3231//something").should be_valid
  end

  it "should clean up some common DOI errors" do
    doi = build(:doi, doi: ' 10.1001/with-a-space-in-front')
    doi.should be_valid
    doi.doi.should == '10.1001/with-a-space-in-front'

    doi = build(:doi, doi: '10.1001/with-spaces-behind  ')
    doi.should be_valid
    doi.doi.should == '10.1001/with-spaces-behind'
  end

  it "should require URL to be in the right format" do
    build(:doi, url: "not a valid url").should_not be_valid
  end

  it "should construct from an OAI-PMH record" do
    doi = Doi.create_or_update_from_oai(@repository, @record)

    doi.repository.should == @repository
    doi.doi.should == "10.1016/j.laa.2007.11.013"
    doi.url.should == "http://opus.bath.ac.uk/167/"
    doi.should be_valid
  end

  it "should update instead of duplicating" do
    doi1 = Doi.create_or_update_from_oai(@repository, @record)
    doi2 = Doi.create_or_update_from_oai(@repository, @record)

    doi1.id.should == doi2.id
  end

  it "should resolve DOIs to URLs" do
    doi1 = create(:doi)
    doi2 = create(:doi)
    
    Doi.resolve(doi1.doi).should == doi1.url
    Doi.resolve(doi2.doi).should == doi2.url
  end

  it "should resolve to nil if it's not in the DB" do
    Doi.resolve("10.1002/not-in-the-database").should be_nil
  end

end
