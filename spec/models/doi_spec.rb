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
    @record_no_fulltext = OAI::Record.new(
      XML::Document.file('spec/fixtures/record_no_fulltext.xml').root)
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
      {
        # Leading whitespace:
        "\t 10.1001/with-a-space-in-front"  => '10.1001/with-a-space-in-front',
        # Trailing whitespace:
        '10.1001/with-spaces-behind  '    => '10.1001/with-spaces-behind',
        # Leading c**p separated by a space:
        ': 10.1039/B706829H'              => '10.1039/B706829H',
        # With lowercase protocol:
        'doi:10.1001/with-protocol'       => '10.1001/with-protocol',
        # With uppercase protocol:
        'DOI:10.1017/S0040298204000014'   => '10.1017/S0040298204000014',
        # URL-encoded:
        '10.1371%2Fjournal.pmed.1001115'  => '10.1371/journal.pmed.1001115',
        # In dx.doi.org URL form:
        'http://dx.doi.org/10.1001/archinte.168.6.598' \
                                          => '10.1001/archinte.168.6.598',
        # Zero-width spaces:
        "10.\u200B1152/\u200Bajpendo.\u200B00325.\u200B2003" \
                                          => '10.1152/ajpendo.00325.2003',
        # Combination of protocol and leading cruft:
        '952-954 doi:10.1353/jsh.2011.0036' \
                                          => '10.1353/jsh.2011.0036',
      }.each do |input, actual|
        mapping = build(:doi_mapping, doi: input)
        mapping.should be_valid, "DOI '#{input}' not valid"
        mapping.doi.should == actual
      end
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
        @mapping.should be_valid
      end

      it "should have the right repository" do
        @mapping.repository.should == @repository
      end
      
      it "should have the right DOI" do
        @mapping.doi.should == doi
      end
      
      it "should have the right URL" do
        @mapping.url.should == url
      end

      it "should have the right value for has_fulltext" do
        @mapping.has_fulltext.should == has_fulltext
      end
    end

    describe "when DOI and URL are dc:relation" do
      it_has_behaviour "construct from OAI::Record" do
        let(:record)  {@record_both_relation}
        let(:doi)     {"10.1016/j.laa.2007.11.013"}
        let(:url)     {"http://opus.bath.ac.uk/167/"}
        let(:has_fulltext) {true}
      end
    end

    describe "when DOI and URL are dc:identifier" do
      it_has_behaviour "construct from OAI::Record" do
        let(:record)  {@record_both_identifier}
        let(:doi)     {"10.6092/issn.1973-9494/1265"}
        let(:url)     {"http://conservation-science.unibo.it/article/view/1265"}
        let(:has_fulltext) {true}
      end
    end

    describe "when no full-text is available" do
      it_has_behaviour "construct from OAI::Record" do
        let(:record)  {@record_no_fulltext}
        let(:doi)     {"10.1039/B706829H"}
        let(:url)     {"http://opus.bath.ac.uk/34244/"}
        let(:has_fulltext) {false}
      end
    end

    it "should update instead of duplicating" do
      mapping1 = described_class.new_or_update_from_oai(@repository, @record_both_relation)
      mapping2 = described_class.new_or_update_from_oai(@repository, @record_both_relation)

      mapping1.id.should == mapping2.id
    end

  end

  describe "attributes" do

    before(:all) { @mapping = create(:doi_mapping) }

    it "should respond to repository" do
      @mapping.should respond_to(:repository)
    end

    it "should respond to doi" do
      @mapping.should respond_to(:doi)
    end

    it "should respond to url" do
      @mapping.should respond_to(:url)
    end

    it "should respond to has_fulltext" do
      @mapping.should respond_to(:has_fulltext)
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
