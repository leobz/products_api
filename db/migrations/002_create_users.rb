Sequel.migration do
  change do
    create_table(:users) do
      primary_key :id
      String :username, null: false
      String :password_hash, null: false
    end
  end
end