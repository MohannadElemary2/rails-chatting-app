class CreateMessages < ActiveRecord::Migration[7.0]
  def change
    create_table :messages do |t|
      t.references :chat, null: false, foreign_key: true
      t.integer :number, null: false
      t.string :creator, null: false
      t.text :body, null: false

      t.timestamps
    end
  end
end
