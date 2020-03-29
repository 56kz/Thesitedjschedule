class SchedulesController < ApplicationController
  before_action :authenticate_student!,  except: [:new ]
  skip_before_action :verify_authenticity_token

  respond_to :html, :json

  def index
    @date_limit=Date.today-60
    @room_id = params[:room_id]
    @user_conected = User.find_by(email: current_student.email)
    @active_suscription = Suscription.find_by(user_id: @user_conected.id, status: true)
    @reservations = Reservation.where("room = ? and reserve_date >= ?", @room_id, @date_limit)
    @reservations_mod =  @reservations.as_json
    @users = User.all

    @reservations.each_with_index  { |item, index|
      @user_id = Suscription.find_by(id: item.suscription_id).user_id
      @user_name=@users.find_by(id: @user_id).name
      @reservations_mod[index][:username]= @user_name
    }


    respond_to do |format|

      format.html {}
      format.json { render json: @reservations_mod }

    end
  end

  def new
    @reservation = Reservation.new(schedules_params)
    @suscription=params[:suscription_id].to_i
    @active_suscription = Suscription.find_by(id: @suscription, status: true)
    @reservation_Hours= Reservation.where(suscription_id: @suscription).count*2
    @suscrip_hours=0
   
    case @active_suscription.hours
      when "Dos"
        @suscrip_hours=2
      when "Cuatro"
        @suscrip_hours=4
      when "Doce"
        @suscrip_hours=12
      when "Full"
        @suscrip_hours=24
    end


    if Reservation.exists?(start_hour: params[:start_hour], reserve_date:params[:reserve_date], room: params[:room])
        render :json => {:result => "Error, schedule already exist!", :status_code => "0"}
    else

      if @suscrip_hours<(@reservation_Hours.to_i+2)
        render :json => { :result => "Not hours available for this suscription!",
                          :status_code => "2", 
                          :available =>@suscrip_hours, 
                          :used => @reservation_Hours}
      else
        if @reservation.save
          render :json => {:result => "Data saved successfully!",:status_code => "1"}
        end
      end
    end

  end

  def destroy

    @user_conected = User.find_by(email: current_student.email)
    @active_suscription = Suscription.find_by(user_id: @user_conected.id, status: true)

    if @active_suscription.id.to_i==params[:suscription_id].to_i or @user_conected.rol!="estudiante"
      Reservation.where(id: params[:id]).destroy_all

      render :json => {
        :result => "Data deleted successfully!",
        :status_code => "1"
      }
    else
      render :json => {:result => "Error, can't delete!", :status_code => "0"}
    end

  end


  private
  def schedules_params
    params.permit(:suscription_id, :schedule_id, :start_hour, :reserve_date, :room)
  end

end
