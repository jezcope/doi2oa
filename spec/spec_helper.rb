$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..'))

require 'sinatra'
require 'rack/test'
require 'rack/utils'
require 'rspec'
require 'factory_girl'
require 'vcr'
require 'database_cleaner'

class Doi2Oa < Sinatra::Base

  configure do
    set :environment, :test
    disable :run
    enable :raise_errors
    disable :logging
  end

end

require 'app'

FactoryGirl.find_definitions

VCR.configure do |c|  
  c.cassette_library_dir = 'spec/cassettes'
  c.hook_into :faraday
  c.configure_rspec_metadata!
end

RSpec.configure do |config|
  config.include FactoryGirl::Syntax::Methods
  config.include Rack::Test::Methods
  config.include Rack::Utils

  config.alias_it_should_behave_like_to :it_has_behaviour, 'has behaviour:'

  before(:suite) do
    DatabaseCleaner[:sequel].strategy = :transaction
    DatabaseCleaner[:sequel].clean_with :truncation, {except: %w{schema_info}}
  end

  before(:each) do
    DatabaseCleaner[:sequel].start
  end

  after(:each) do
    DatabaseCleaner[:sequel].clean
  end

end

