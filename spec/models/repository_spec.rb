require 'spec_helper'

require 'models/repository'

describe Repository, :models => true do

  it "should be valid with valid parameters" do
    FactoryGirl.build(:repository).should be_valid
  end

  it "should require a base URL" do
    Repository.new.should_not be_valid
  end

end
