class AddUserIdToFeedEntries < ActiveRecord::Migration
  def change
    add_column :feed_entries, :user_id, :integer

  end
end
