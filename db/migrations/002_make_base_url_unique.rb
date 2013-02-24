Sequel.migration do
  change do
    alter_table(:repositories) do
      add_unique_constraint :base_url
    end
  end
end

