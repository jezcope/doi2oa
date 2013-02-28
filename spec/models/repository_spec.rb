require 'spec_helper'

require 'models/repository'

describe Repository, :models => true do

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

  describe "OAI-PMH" do

    describe "identify",
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

    describe "list records",
      vcr: { cassette_name: "repository/list_records",
        record: :new_episodes } do

      before(:all) do
        @repository = Repository.find_or_create(base_url: "http://opus.bath.ac.uk/cgi/oai2")
      end
        
      it "should fetch records from the server" do
        records, resumption_token = @repository.list_records
        records.length.should == 13
        records.each do |doi|
          doi.repository.should == @repository
        end
      end

      it "should fetch more records from the server" do
        records, resumption_token = @repository.list_records
        records, resumption_token = @repository.list_records resumption_token

        records.length.should == 16
        records.each do |doi|
          doi.repository.should == @repository
        end
      end

    end

  end

end
