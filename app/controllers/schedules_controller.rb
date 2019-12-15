class SchedulesController < ApplicationController
  #before_action :authenticate_student!
  
  respond_to :html, :json

  def index
 
    @room_id=params[:room_id]
    @user_conected = User.find_by(email: current_student.email)
    @active_suscription = Suscription.find_by(user_id: @user_conected.id, status: true)
    @reservations = Reservation.where(room: @room_id)
    

    respond_to do |format|

      format.html # show.html.erb
      format.json { render json: @reservations }
    
     end

  end

  def new

    @reservation = Reservation.new(schedules_params)
    puts schedules_params
    
    if @reservation.save
      render :json => {:result => "Data saved successfully!"}
    end
  end


  private
  def schedules_params
    params.permit(:suscription_id, :schedule_id, :start_hour, :reserve_date, :room)
  end

end
