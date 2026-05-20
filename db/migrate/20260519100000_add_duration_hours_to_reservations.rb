class AddDurationHoursToReservations < ActiveRecord::Migration[8.0]
  def change
    add_column :reservations, :duration_hours, :integer, default: 2, null: false
  end
end
