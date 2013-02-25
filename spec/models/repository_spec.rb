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
    Repository.new(base_url: "http://repo.example.com/oai2")
      .should be_valid
  end

  it "should not allow duplicate URLs" do
    build(:repository,
          base_url: "http://repo2.example.com/oai2")
      .save
    build(:repository,
          base_url: "http://repo2.example.com/oai2")
      .should_not be_valid
  end

  it "should require base_url to be a valid URL" do
    Repository.new(base_url: "Not a URL")
      .should_not be_valid
  end

  vcr_options = { 
    cassette_name: "repository/identify", record: :new_episodes }
  describe "server interaction", vcr: vcr_options do

    it "should fetch information from the server" do

      r = Repository.new(base_url: "http://opus.bath.ac.uk/cgi/oai2")
      r.fetch_info_from_server

      r.name.should               == "Opus"
      r.admin_email.should        == "opus-support@bath.ac.uk"
      r.earliest_datestamp.should == "2008-12-05T11:39:41Z"
    end

  end

end
