class SchedulesController < ApplicationController
  before_action :authenticate_student!
  
  def index
    @schedules = Schedule.where(room_id: params[:room_id])
    @reservations = Reservation.all
  end

end
