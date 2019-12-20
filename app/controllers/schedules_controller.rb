class SchedulesController < ApplicationController
  before_action :authenticate_student!,  except: [:new]

  respond_to :html, :json

  def index
    @room_id = params[:room_id]
    @user_conected = User.find_by(email: current_student.email)
    @active_suscription = Suscription.find_by(user_id: @user_conected.id, status: true)
    @reservations = Reservation.where(room: @room_id)

    respond_to do |format|

      format.html {}
      format.json { render json: @reservations }

    end
  end

  def new
    @reservation = Reservation.new(schedules_params)

    if Reservation.exists?(start_hour: params[:start_hour], reserve_date:params[:reserve_date], room: params[:room])
        render :json => {:result => "Error, schedule already exist!", :status_code => "0"}
    else
      if @reservation.save
        render :json => {:result => "Data saved successfully!",:status_code => "1"}
      end
    end

  end


  private
  def schedules_params
    params.permit(:suscription_id, :schedule_id, :start_hour, :reserve_date, :room)
  end

end
