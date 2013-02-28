$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..'))

require 'rspec'
require 'factory_girl'
require 'vcr'

require 'db/init'

FactoryGirl.find_definitions

VCR.configure do |c|  
  c.cassette_library_dir = 'spec/cassettes'
  c.hook_into :faraday
  c.configure_rspec_metadata!
end

RSpec.configure do |config|
  config.include FactoryGirl::Syntax::Methods
end
