class CreateSchedules < ActiveRecord::Migration[5.2]
  def change
    create_table :schedules do |t|
      t.date :day
      t.integer :hour
      t.references :room, foreign_key: true

      t.timestamps
    end
  end
end
