class CreateBlockedSlots < ActiveRecord::Migration[8.0]
  def change
    create_table :blocked_slots do |t|
      t.references :room, null: false, foreign_key: true
      t.integer    :start_hour, null: false
      t.integer    :duration_hours, default: 2, null: false
      t.date       :block_date, null: false
      t.references :user, null: false, foreign_key: true
      t.timestamps
    end

    add_index :blocked_slots, [:room_id, :block_date, :start_hour], unique: true
  end
end
