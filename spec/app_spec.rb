require 'spec_helper'

describe Doi2Oa do

  def app
    described_class
  end

  describe "/" do
    
    before(:each) { get '/' }

    it "should respond to get" do
      last_response.should be_ok
    end

    it "should return some HTML" do
      last_response.body.should match /<html.*>/
    end

  end

  describe "/repositories" do

    before do
      @repos = (1..5).map {create(:repository)}
      get '/repositories'
    end

    it "should respond to GET" do
      last_response.should be_ok
    end

    it "should list information about each repository" do
      @repos.each do |r|
        last_response.body.should include(r.name)
        last_response.body.should include(escape_html r.base_url)
        last_response.body.should include(r.admin_email)
      end
    end

  end
      
  describe "/resolve" do

    before do
      @dois = (1..5).map {create(:doi)}
    end

    describe "without parameters" do

      it "should be a bad request" do
        get '/resolve'
        last_response.status.should == 400
      end

    end
    
    describe "with parameters" do
        
      it "should return the correct URL" do
        @dois.each do |record|
          get "/resolve?doi=#{CGI::escape(record.doi)}"
          last_response.body.should == record.url
        end
      end
      
      it "should 404 with a non-existent DOI" do
        get "/resolve?doi=10.1000/not-in-database"
        last_response.status.should == 404
      end
      
    end
    
    describe "with pathinfo" do
    
      it "should return the correct URL" do
        @dois.each do |record|
          get "/resolve/#{record.doi}"
          last_response.body.should == record.url
        end
      end
      
      it "should 404 with a non-existent DOI" do
        get "/resolve/10.1000/not-in-database"
        last_response.status.should == 404
      end
      
    end

  end

  describe "/redirect" do

    before do
      @dois = (1..5).map {create(:doi)}
    end

    describe "without parameters" do

      it "should be a bad request" do
        get '/redirect'
        last_response.status.should == 400
      end

    end
    
    describe "with parameters" do
        
      it "should redirect to the correct URL" do
        @dois.each do |record|
          get "/redirect?doi=#{CGI::escape(record.doi)}"
          last_response.should be_redirect
          last_response.location.should == record.url
        end
      end
      
      it "should 404 with a non-existent DOI" do
        get "/redirect?doi=10.1000/not-in-database"
        last_response.status.should == 404
      end
      
    end
    
    describe "with pathinfo" do
    
      it "should redirect to the correct URL" do
        @dois.each do |record|
          get "/redirect/#{record.doi}"
          last_response.should be_redirect
          last_response.location.should == record.url
        end
      end
      
      it "should 404 with a non-existent DOI" do
        get "/redirect/10.1000/not-in-database"
        last_response.status.should == 404
      end
      
    end

  end

end
