class AddStartHourToReservations < ActiveRecord::Migration[5.2]
  def change
    add_column :reservations, :start_hour, :integer
  end
end
