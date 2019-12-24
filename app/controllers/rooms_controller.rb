class RoomsController < ApplicationController
  before_action :authenticate_student!

  def index
    @user_conected = User.find_by(email: current_student.email)
    @active_suscription = Suscription.find_by(user_id: @user_conected.id, status: true)
    @array_of_rooms = @active_suscription.rooms.split(',')
    new_array = []

    @array_of_rooms.each do |r|
      room = Room.find_by(id: r)
      new_array.push(room)
    end
    @rooms = new_array

  end
end
