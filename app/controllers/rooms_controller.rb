class RoomsController < ApplicationController
  before_action :authenticate_student!

  def index
    @rooms = Room.all
  end
end
