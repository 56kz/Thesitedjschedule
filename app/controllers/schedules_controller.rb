class SchedulesController < ApplicationController
  def index
    @schedules = Schedule.all
    @reservations = Reservation.all
  end

end
