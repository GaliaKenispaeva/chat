class CreateRoomUsersTable < ActiveRecord::Migration[5.2]
  def change
    create_table :room_users do |t|
      t.references :room, foreign_key: true
      t.references :user, foreign_key: true
    end
  end
end
