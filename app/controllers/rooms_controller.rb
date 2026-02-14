class RoomsController < ApplicationController
  before_action :authenticate_student!

  def index
    @user_conected = User.find_by(email: current_student.email)
    unless @user_conected
      @rooms = []
      return
    end

    @active_suscription = Suscription.find_by(user_id: @user_conected.id, status: true)
    if @active_suscription&.rooms.present?
      @array_of_rooms = @active_suscription.rooms.split(',')
      @rooms = Room.where(id: @array_of_rooms)
    else
      @rooms = []
    end
  end
end
