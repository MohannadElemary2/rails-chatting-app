class AddIndexToApplications < ActiveRecord::Migration[7.0]
  def change
    add_index :applications, :token
  end
end
