class CreateFeedEntries < ActiveRecord::Migration
  def change
    create_table :feed_entries do |t|
      t.string :guid
      t.string :track
      t.string :album
      t.string :artist
      t.string :album_art_url
      t.string :item_type

      t.timestamps
    end
  end
end
