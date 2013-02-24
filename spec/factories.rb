require 'active_support/all'

FactoryGirl.define do

  factory :repository do
    base_url    "http://repo.example.com/oai2"
    name        "Example repository"
    admin_email "repo@example.com"
    earliest_datestamp 5.years.ago
  end

end
