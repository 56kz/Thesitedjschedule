class AddReserveRoomToReservations < ActiveRecord::Migration[5.2]
  def change
    add_column :reservations, :room, :string
  end
end
