Sequel.migration do
  up do
    add_column :reviews, :thumbs_up, Integer, default: 0, null: false
    add_column :reviews, :thumbs_down, Integer, default: 0, null: false
  end

  down do
    drop_column :reviews, :thumbs_up
    drop_column :reviews, :thumbs_down
  end
end
