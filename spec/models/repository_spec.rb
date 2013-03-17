require 'spec_helper'

require 'models/repository'

describe Repository, :models => true do

  describe "construction" do

    it "should be valid with valid parameters" do
      build(:repository).should be_valid
    end

    it "should require a base URL" do
      Repository.new.should_not be_valid
    end

    it "should not require any other parameters" do
      r = Repository.new(base_url: "http://repo.example.com/oai2")
      r.should be_valid
      r.name.should be_nil
      r.admin_email.should be_nil
      r.earliest_datestamp.should be_nil
    end

    it "should not allow duplicate URLs" do
      Repository.find_or_create(base_url: "http://repo2.example.com/oai2")
      Repository.new(base_url: "http://repo2.example.com/oai2")
        .should_not be_valid
    end

    it "should require base_url to be a valid URL" do
      build(:repository, base_url: "Not a URL").should_not be_valid
    end

    it "should allow base_url with a port" do
      build(:repository, base_url: "http://ora.ox.ac.uk:8080/fedora/oai").should_not be_valid
    end

  end

  describe "OAI-PMH" do

    describe "#identify!",
      vcr: { cassette_name: "repository/identify", 
        record: :new_episodes } do

      it "should fetch its identity from the server" do
        r = Repository.new(base_url: "http://opus.bath.ac.uk/cgi/oai2")
        r.identify!

        r.name.should               == "Opus"
        r.admin_email.should        == "opus-support@bath.ac.uk"
        r.earliest_datestamp.should == "2008-12-05T11:39:41Z"
      end

    end

    describe "#list_records",
      vcr: { cassette_name: "repository/list_records",
        allow_playback_repeats: true} do

      before(:all) do
        @repository = Repository.find_or_create(base_url: "http://opus.bath.ac.uk/cgi/oai2")
      end
        
      it "should fetch records with a limit" do
        records = @repository.list_records(limit: 20)
        records.length.should == 20
        records.each do |doi_mapping|
          doi_mapping.class.should == DoiMapping
          doi_mapping.should be_valid
          doi_mapping.repository.should == @repository
        end
      end

      it "should fetch all records" do
        records = @repository.list_records
        records.length.should == 48
        records.each do |doi_mapping|
          doi_mapping.class.should == DoiMapping
          doi_mapping.should be_valid
          doi_mapping.repository.should == @repository
        end
      end

      it "should not save DOI records by default" do
        records = @repository.list_records(limit: 10)
        records.each do |r|
          r.should be_modified
        end
      end

      it "should not save DOI records with save: false" do
        records = @repository.list_records(limit: 10, save: false)
        records.each do |r|
          r.should be_modified
        end
      end

      it "should save DOI records with save: true" do
        records = @repository.list_records(limit: 10, save: true)
        records.each do |r|
          r.should_not be_modified
        end
      end

      it "should update instead of duplicating DOI records" do
        records = @repository.list_records(limit: 10, save: true)
        count_before = DoiMapping.count

        records = @repository.list_records(limit: 10, save: true)
        DoiMapping.count.should == count_before
      end

    end

  end

end
