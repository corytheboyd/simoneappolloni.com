Sequel.migration do
  up do
    add_column :reviews, :page_url, String
  end

  down do
    drop_column :reviews, :page_url
  end
end
