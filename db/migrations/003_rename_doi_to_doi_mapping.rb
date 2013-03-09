Sequel.migration do
  change do
    rename_table :dois, :doi_mappings
  end
end
