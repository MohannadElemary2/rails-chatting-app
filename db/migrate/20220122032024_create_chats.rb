class CreateChats < ActiveRecord::Migration[7.0]
  def change
    create_table :chats do |t|
      t.references :application, null: false, foreign_key: true
      t.integer :number, null: false
      t.string :creator, null: false
      t.integer :messages_count, default: 0
      t.boolean :has_new_messages, default: 0

      t.timestamps
    end
  end
end
