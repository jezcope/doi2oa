require 'spec_helper'

require 'models/doi'
require 'models/repository'

describe Doi, :models => true do

  it "should be valid with valid parameters" do
    build(:doi).should be_valid
  end

  it "should require a repository" do
    build(:doi, repository: nil).should_not be_valid
  end

  it "should require a DOI" do
    expect { build(:doi, doi: nil) }.to raise_error
  end

end
