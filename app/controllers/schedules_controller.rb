class SchedulesController < ApplicationController
  def index
    @schedules = Schedule.where(room_id: params[:room_id])
    @reservations = Reservation.all
  end

end
