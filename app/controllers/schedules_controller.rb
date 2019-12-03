class SchedulesController < ApplicationController
  def index
    @schedules = Schedule.where(room_id: params[:room_id])
    @reservations = Reservation.all

    @lunes = []
    @martes = []
    @sabado = []
    @schedules.each do |s|
      if s.name.include?("Lunes")
        @lunes.push(s)
      elsif s.name.include?("Martes")
        @martes.push(s)
      else
        @sabado.push(s)
      end
    end
  end

end
