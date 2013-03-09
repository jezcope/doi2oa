require 'spec_helper'

require 'xml'

require 'models/doi_mapping'
require 'models/repository'

describe DoiMapping, :models => true do

  before(:all) do
    @record_both_relation = OAI::Record.new(
      XML::Document.file('spec/fixtures/record_both_relation.xml').root)
    @record_both_identifier = OAI::Record.new(
      XML::Document.file('spec/fixtures/record_both_identifier.xml').root)
    @repository = create(:repository)
  end

  describe ".new" do

    it "should be valid with valid parameters" do
      build(:doi_mapping).should be_valid
    end

    it "should require a repository" do
      build(:doi_mapping, repository: nil).should_not be_valid
    end

    it "should require a DOI" do
      expect { create(:doi_mapping, doi: nil) }.to raise_error
    end

    it "should require DOI to be in the right format" do
      build(:doi_mapping, doi: "not a valid doi").should_not be_valid
      build(:doi_mapping, doi: "23.1234/something").should_not be_valid
      build(:doi_mapping, doi: "23.1*234/something").should_not be_valid

      build(:doi_mapping, doi: "10.1001/a.long(wierd)-doi/234.2").should be_valid
      build(:doi_mapping, doi: "10.3231//something").should be_valid
    end

    it "should clean up some common DOI errors" do
      mapping = build(:doi_mapping, doi: ' 10.1001/with-a-space-in-front')
      mapping.should be_valid
      mapping.doi.should == '10.1001/with-a-space-in-front'

      mapping = build(:doi_mapping, doi: '10.1001/with-spaces-behind  ')
      mapping.should be_valid
      mapping.doi.should == '10.1001/with-spaces-behind'
    end

    it "should require URL to be in the right format" do
      build(:doi_mapping, url: "not a valid url").should_not be_valid
    end

  end

  describe ".new_or_update_from_oai" do

    shared_examples_for "construct from OAI::Record" do
      before(:each) do
        @mapping = described_class.new_or_update_from_oai(@repository, record)
      end

      it "should construct a valid mapping" do
        @mapping.class.should == described_class
        @mapping.repository.should == @repository
        @mapping.doi.should == doi
        @mapping.url.should == url
        @mapping.should be_valid
      end
    end

    describe "when DOI and URL are dc:relation" do
      it_has_behaviour "construct from OAI::Record" do
        let(:record)  {@record_both_relation}
        let(:doi)     {"10.1016/j.laa.2007.11.013"}
        let(:url)     {"http://opus.bath.ac.uk/167/"}
      end
    end

    describe "when DOI and URL are dc:identifier" do
      it_has_behaviour "construct from OAI::Record" do
        let(:record)  {@record_both_identifier}
        let(:doi)     {"10.6092/issn.1973-9494/1265"}
        let(:url)     {"http://conservation-science.unibo.it/article/view/1265"}
      end
    end

    it "should update instead of duplicating" do
      mapping1 = described_class.new_or_update_from_oai(@repository, @record_both_relation)
      mapping2 = described_class.new_or_update_from_oai(@repository, @record_both_relation)

      mapping1.id.should == mapping2.id
    end

  end

  describe ".resolve" do

    it "should resolve DOIs to URLs" do
      mapping1 = create(:doi_mapping)
      mapping2 = create(:doi_mapping)
      
      described_class.resolve(mapping1.doi).should == mapping1.url
      described_class.resolve(mapping2.doi).should == mapping2.url
    end

    it "should resolve to nil if it's not in the DB" do
      described_class.resolve("10.1002/not-in-the-database").should be_nil
    end

  end

end
