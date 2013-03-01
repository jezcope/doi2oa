Sequel.migration do
  change do
    create_table(:repositories) do
      primary_key :id
      String :base_url, null: false
      String :name
      String :admin_email
      DateTime :earliest_datestamp
    end

    create_table(:dois) do
      primary_key :id
      foreign_key :repository_id, :repositories
      String :doi, null: false, index: true
      String :url
    end
  end
end
