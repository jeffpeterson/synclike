class AddPandoraUsernameToUsers < ActiveRecord::Migration
  def change
    add_column :users, :pandora_username, :string

  end
end
