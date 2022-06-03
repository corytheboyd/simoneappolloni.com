Sequel.migration do
  up do
    create_table(:artists) do
      primary_key :id
      String :name, null: false
    end

    create_table(:albums) do
      primary_key :id
      String :name, null: false
    end

    create_table(:reviews) do
      primary_key :id
      String :body, null: false
      Integer :rating, null: false
    end
  end

  down do
    drop_table(:artists)
    drop_table(:albums)
    drop_table(:reviews)
  end
end
