class SchedulesController < ApplicationController
  before_action :authenticate_student!
  skip_before_action :verify_authenticity_token

  respond_to :html, :json

  def index
    @date_limit=Date.current-60
    @room_id = params[:room_id]
    @user_conected = User.find_by(email: current_student.email)
    @active_suscription = Suscription.find_by(user_id: @user_conected.id, status: true)
    @reservations = Reservation.where("room = ? and reserve_date >= ?", @room_id, @date_limit)
    @reservations_mod =  @reservations.as_json
    @users = User.all

    @reservations.each_with_index  { |item, index|
      @user_id = Suscription.find_by(id: item.suscription_id).user_id
      @suscription_name=Suscription.find_by(id: item.suscription_id).name
      @user_name=@users.find_by(id: @user_id).name
      @reservations_mod[index][:username]= @user_name
      @reservations_mod[index][:suscription]= @suscription_name
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

          if params[:reserve_date].to_date < Date.current

            render :json => {
              :result => "Can't create",
              :status_code => "3"
            }

          else

          if @suscrip_hours<0#(@reservation_Hours.to_i+2)
            render :json => { :result => "Not hours available for this suscription!",
                              :status_code => "2", 
                              :available =>@suscrip_hours, 
                              :used => @reservation_Hours}
          else

          
            #Domingo 0 sabado 6
            @dow=params[:reserve_date].to_date.wday
            @finde=false
            @out_of=false
            @inicio=params[:start_hour]
            @current_date=Date.current
            @current_time= Time.current

            @schedule_ini_semana=Time.new(@current_date.year,@current_date.month,@current_date.day, 6,0,0)
            @schedule_fin_semana=Time.new(@current_date.year,@current_date.month,@current_date.day, 19,0,0)

            @schedule_ini_finde=Time.new(@current_date.year,@current_date.month,@current_date.day, 8,0,0)
            @schedule_fin_finde=Time.new(@current_date.year,@current_date.month,@current_date.day, 16,0,0)
            
            if ((@dow == 6 or @dow == 0) and (@inicio == '08' or @inicio == '18' or @inicio == '06' or @inicio == '20')) 
              @finde = true
            end

            # Validar que la programación se da en el horario habilitado.
            if @finde
              if (@current_time-@schedule_ini_finde)>0 and (@schedule_fin_finde-@current_time)>0
                @out_of=false
              else
                @out_of=true
              end 
            else
              if (@current_time-@schedule_ini_semana)>0 and (@schedule_fin_semana-@current_time)>0
                @out_of=false
              else
                @out_of=true
              end 
            end


            if !@finde

              if !@out_of

                  if @reservation.save
                    @users = User.all
                    @room_id = params[:room_id]
                    @user_conected = User.find_by(email: current_student.email)
                    @active_suscription = Suscription.find_by(user_id: @user_conected.id, status: true)
                    @reservations = Reservation.find_by(id: @reservation.id)
                    @reservations_mod =  @reservations.as_json
                
                    @user_id = Suscription.find_by(id: @reservations.suscription_id).user_id
                    @suscription_name=Suscription.find_by(id: @reservations.suscription_id).name
                    @user_name=@users.find_by(id: @user_id).name
                    @reservations_mod[:username]= @user_name
                    @reservations_mod[:suscription]= @suscription_name
                    @reservations_mod[:result]= "Data saved successfully!"
                    @reservations_mod[:status_code]= "1"
                    render :json => @reservations_mod
                  end

                else 

                  render :json => {
                    :result => "Can't create at this moment",
                    :status_code => "4"
                  }

                end

              else

                render :json => {
                  :result => "Can't create",
                  :status_code => "0"
                }

              end

          end

        end

    end

  end

  def destroy

    @user_conected = User.find_by(email: current_student.email)
    @active_suscription = Suscription.find_by(user_id: @user_conected.id, status: true)

    if @active_suscription.id.to_i==params[:suscription_id].to_i or @user_conected.rol!="estudiante"
      
      @reserve_to_del=Reservation.find_by(id: params[:id])
      @reserve_date=@reserve_to_del.reserve_date.to_date
      @current_date=Date.current
      @current_time= Time.current
      @schedule_time=Time.new(@reserve_date.year,@reserve_date.month,@reserve_date.day, @reserve_to_del.start_hour,0,0)
      @remaining=(@schedule_time-@current_time)/60


            #Domingo 0 sabado 6
            @dow=@reserve_date.to_date.wday
            @out_of=false
            @inicio=params[:start_hour]


            @schedule_ini_semana=Time.new(@current_date.year,@current_date.month,@current_date.day, 6,0,0)
            @schedule_fin_semana=Time.new(@current_date.year,@current_date.month,@current_date.day, 19,0,0)

            @schedule_ini_finde=Time.new(@current_date.year,@current_date.month,@current_date.day, 8,0,0)
            @schedule_fin_finde=Time.new(@current_date.year,@current_date.month,@current_date.day, 16,0,0)
            
            if ((@dow == 6 or @dow == 0) and (@inicio == '08' or @inicio == '18' or @inicio == '06' or @inicio == '20')) 
              @finde = true
            end

            # Validar que la programación se da en el horario habilitado.
            if @finde
              if (@current_time-@schedule_ini_finde)>0 and (@schedule_fin_finde-@current_time)>0
                @out_of=false
              else
                @out_of=true
              end 
            else
              if (@current_time-@schedule_ini_semana)>0 and (@schedule_fin_semana-@current_time)>0
                @out_of=false
              else
                @out_of=true
              end 
            end

      if @reserve_to_del.reserve_date>= @current_date
      
        #Cancelar con 1 hora de antelación
          if @remaining>60 or @user_conected.rol!="estudiante"

              if !@out_of
                  Reservation.where(id: params[:id]).destroy_all
                  render :json => {
                    :result => "Data deleted successfully!",
                    :status_code => "1"
                  }
              else
                render :json => {
                  :result => "Can't delete at this moment",
                  :status_code => "4"
                }
              end

            else
              render :json => {:result => "Error, can't delete!", :status_code => "3"}
            end
      
      else
        render :json => {:result => "Error, can't delete!", :status_code => "2"}
      end
 
    else
      render :json => {:result => "Error, can't delete!", :status_code => "0"}
    end

  end


  private
  def schedules_params
    params.permit(:suscription_id, :schedule_id, :start_hour, :reserve_date, :room)
  end

end
