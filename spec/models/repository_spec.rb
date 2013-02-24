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

  describe "server interaction" do

    before do
      require 'oai'

      @response = double("response",
                        repository_name:  "Test repo",
                        admin_email:      "example@bath.ac.uk",
                        earliest_datestamp: 3.years.ago)
      @client = double("client", identify: @response)
      OAI::Client.stub(:new).and_return(@client)
    end

    it "should fetch information from the server" do
      r = Repository.new(base_url: "http://opus.bath.ac.uk/cgi/oai2")
      r.fetch_info_from_server

      r.name.should               == @response.repository_name
      r.admin_email.should        == @response.admin_email
      r.earliest_datestamp.should == @response.earliest_datestamp
    end

  end

end
