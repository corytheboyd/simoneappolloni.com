Sequel.migration do
  up do
    create_table(:users) do
      primary_key :id
      String :username, null: false
    end

    create_table(:artists) do
      primary_key :id
      String :name, unique: true, null: false
    end

    create_table(:albums) do
      primary_key :id
      String :name, null: false
    end

    alter_table(:albums) do
      add_foreign_key :artist_id, :albums
    end

    create_table(:reviews) do
      primary_key :id
      String :body, null: false
      Integer :rating, null: false
    end

    alter_table(:reviews) do
      add_foreign_key :user_id, :users
      add_foreign_key :album_id, :reviews
    end
  end

  down do
    drop_table(:artists)
    drop_table(:albums)
    drop_table(:reviews)
  end
end
