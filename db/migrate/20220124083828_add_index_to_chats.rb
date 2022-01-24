class AddIndexToChats < ActiveRecord::Migration[7.0]
  def change
    add_index :chats, [:number, :application_id]
  end
end
