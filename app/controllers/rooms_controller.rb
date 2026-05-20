class RoomsController < ApplicationController
  before_action :authenticate_student!

  def index
    @user_conected = User.find_by(email: current_student.email)
    unless @user_conected
      @rooms = []
      @active_suscriptions = []
      return
    end

    @active_suscriptions = Suscription.active_and_valid.where(user_id: @user_conected.id)

    room_ids = @active_suscriptions.flat_map { |s| s.rooms.to_s.split(',').map(&:strip) }.uniq
    @rooms = room_ids.any? ? Room.where(id: room_ids) : []

    suscription_ids = @active_suscriptions.pluck(:id)
    if suscription_ids.any?
      now = Time.current
      @next_reservation = Reservation
        .where(suscription_id: suscription_ids)
        .where("reserve_date > ? OR (reserve_date = ? AND start_hour >= ?)", Date.current, Date.current, now.hour)
        .order(:reserve_date, :start_hour)
        .first
      @next_reservation_room = Room.find_by(id: @next_reservation.room) if @next_reservation

      # Estado por sala: ¿tiene una reserva futura el usuario en esa sala?
      @room_has_reservation = {}
      @rooms.each do |r|
        @room_has_reservation[r.id] = Reservation
          .where(suscription_id: suscription_ids, room: r.id.to_s)
          .where("reserve_date >= ?", Date.current)
          .exists?
      end
    else
      @room_has_reservation = {}
    end
  end
end
