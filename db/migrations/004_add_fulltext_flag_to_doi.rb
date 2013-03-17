Sequel.migration do
  change do
    add_column :doi_mappings, :has_fulltext, FalseClass, default: false
  end
end
