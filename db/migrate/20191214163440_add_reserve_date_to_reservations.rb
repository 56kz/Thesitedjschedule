class AddReserveDateToReservations < ActiveRecord::Migration[5.2]
  def change
    add_column :reservations, :reserve_date, :date
  end
end
