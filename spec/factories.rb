require 'active_support/all'

FactoryGirl.define do

  to_create {|instance| instance.save(raise_on_failure: true)}

  factory :repository do
    sequence(:base_url) {|n| "http://repo#{n}.example.com/oai2"}
    name        "Example repository"
    admin_email "repo@example.com"
    earliest_datestamp 5.years.ago
  end

  factory :doi do
    doi         "10.1000/foobar"
    url         "http://repo.example.com/document"
    repository
  end

end
