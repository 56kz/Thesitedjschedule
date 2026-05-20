class SchedulesController < ApplicationController
  before_action :authenticate_student!

  respond_to :html, :json

  def index
    @date_limit = Date.current - 60
    @room_id = params[:room_id]
    @room = Room.find_by(id: @room_id)
    @user_conected = User.find_by(email: current_student.email)
    @active_suscriptions = active_suscriptions_for_room(@user_conected, @room_id)

    if @active_suscriptions.empty? && @user_conected&.rol == "estudiante"
      redirect_to root_path, alert: "No tienes una suscripción activa para esta sala."
      return
    end

    @reservations = Reservation.where("room = ? and reserve_date >= ?", @room_id, @date_limit)
    @reservations_mod = @reservations.as_json
    @users = User.all

    @reservations.each_with_index do |item, index|
      suscription = Suscription.find_by(id: item.suscription_id)
      next unless suscription
      user_name = @users.find_by(id: suscription.user_id)&.name || "Desconocido"
      @reservations_mod[index][:username] = user_name
      @reservations_mod[index][:suscription] = suscription.name
    end

    # Agregar bloques como eventos especiales
    blocked = BlockedSlot.where("room_id = ? and block_date >= ?", @room_id, @date_limit)
    blocked.each do |b|
      @reservations_mod << {
        id:             "block_#{b.id}",
        reserve_date:   b.block_date.to_s,
        start_hour:     b.start_hour,
        duration_hours: b.duration_hours,
        room:           @room_id.to_s,
        suscription_id: nil,
        username:       "Bloqueado",
        suscription:    "Bloqueado",
        blocked:        true,
        blocked_slot_id: b.id
      }
    end

    respond_to do |format|
      format.html {}
      format.json { render json: @reservations_mod }
    end
  end

  def new
    @user_conected = User.find_by(email: current_student.email)
    @reservation = Reservation.new(schedules_params)
    @suscription_id = params[:suscription_id].to_i
    @active_suscription = Suscription.active_and_valid.find_by(id: @suscription_id)
    @duration = [params[:duration_hours].to_i, 1].max
    @duration = [@duration, 2].min

    if @active_suscription.nil?
      render json: { result: "Suscripción no válida o vencida.", status_code: "0" } and return
    end

    if @user_conected.rol == "estudiante" && !suscription_allows_room?(@active_suscription, params[:room])
      render json: { result: "Tu suscripción no tiene acceso a esta sala.", status_code: "0" } and return
    end

    @suscrip_hours = @active_suscription.hours_total
    @reservation_hours_used = @active_suscription.hours_used

    if Reservation.exists?(start_hour: params[:start_hour], reserve_date: params[:reserve_date], room: params[:room])
      render json: { result: "Error, schedule already exist!", status_code: "0" } and return
    end

    if BlockedSlot.exists?(room_id: params[:room], block_date: params[:reserve_date], start_hour: params[:start_hour])
      render json: { result: "Este horario está bloqueado.", status_code: "0" } and return
    end

    if params[:reserve_date].to_date < Date.current
      render json: { result: "Can't create", status_code: "3" } and return
    end

    if @suscrip_hours < (@reservation_hours_used.to_i + @duration)
      render json: {
        result: "Not hours available for this suscription!",
        status_code: "2",
        available: @suscrip_hours,
        used: @reservation_hours_used
      } and return
    end

    @dow = params[:reserve_date].to_date.wday
    @finde = false
    @out_of = false
    @inicio = params[:start_hour]
    @current_date = Date.current
    @current_time = Time.current

    @schedule_hour = Time.new(
      params[:reserve_date].to_date.year,
      params[:reserve_date].to_date.month,
      params[:reserve_date].to_date.day,
      params[:start_hour], 0, 0
    )

    @schedule_ini_semana = Time.new(@current_date.year, @current_date.month, @current_date.day, 6, 0, 0)
    @schedule_fin_semana = Time.new(@current_date.year, @current_date.month, @current_date.day, 19, 0, 0)
    @schedule_ini_finde = Time.new(@current_date.year, @current_date.month, @current_date.day, 8, 0, 0)
    @schedule_fin_finde = Time.new(@current_date.year, @current_date.month, @current_date.day, 16, 0, 0)

    if (@dow == 6 || @dow == 0) && (@inicio == '08' || @inicio == '18' || @inicio == '06' || @inicio == '20')
      @finde = true
    end

    if @finde
      @out_of = !((@current_time - @schedule_ini_finde) > 0 &&
                  (@schedule_fin_finde - @current_time) > 0 &&
                  (@schedule_hour - @current_time) > 3600)
    else
      @out_of = !((@current_time - @schedule_ini_semana) > 0 &&
                  (@schedule_fin_semana - @current_time) > 0 &&
                  (@schedule_hour - @current_time) > 3600)
    end

    if @finde && @user_conected.rol == "estudiante"
      render json: { result: "Can't create", status_code: "0" } and return
    end

    # La restricción de horario de oficina solo aplica para reservas del mismo día.
    # Para fechas futuras, el estudiante puede reservar a cualquier hora.
    if @out_of && @user_conected.rol == "estudiante" && params[:reserve_date].to_date == Date.current
      render json: { result: "Can't create at this moment", status_code: "4" } and return
    end

    @reservation.duration_hours = @duration

    if @reservation.save
      @users = User.all
      saved = Reservation.find(@reservation.id).as_json
      user_id = Suscription.find_by(id: saved["suscription_id"]).user_id
      suscription_name = Suscription.find_by(id: saved["suscription_id"]).name
      user_name = @users.find_by(id: user_id).name
      saved[:username] = user_name
      saved[:suscription] = suscription_name
      saved[:result] = "Data saved successfully!"
      saved[:status_code] = "1"
      render json: saved
    end
  end

  def destroy
    @user_conected = User.find_by(email: current_student.email)
    @reserve_to_del = Reservation.find_by(id: params[:id])

    unless @reserve_to_del
      render json: { result: "Error, reservation not found!", status_code: "0" } and return
    end

    # Estudiante solo puede cancelar sus propias reservas
    if @user_conected.rol == "estudiante"
      user_suscription_ids = Suscription.where(user_id: @user_conected.id).pluck(:id)
      unless user_suscription_ids.include?(@reserve_to_del.suscription_id)
        render json: { result: "Error, can't delete!", status_code: "0" } and return
      end
    end

    @reserve_date = @reserve_to_del.reserve_date.to_date
    @current_date = Date.current
    @current_time = Time.current
    @schedule_time = Time.new(@reserve_date.year, @reserve_date.month, @reserve_date.day, @reserve_to_del.start_hour, 0, 0)
    @remaining = (@schedule_time - @current_time) / 60

    @dow = @reserve_date.wday
    @inicio = params[:start_hour]
    @current_date = Date.current

    @schedule_ini_semana = Time.new(@current_date.year, @current_date.month, @current_date.day, 6, 0, 0)
    @schedule_fin_semana = Time.new(@current_date.year, @current_date.month, @current_date.day, 19, 0, 0)
    @schedule_ini_finde = Time.new(@current_date.year, @current_date.month, @current_date.day, 8, 0, 0)
    @schedule_fin_finde = Time.new(@current_date.year, @current_date.month, @current_date.day, 16, 0, 0)

    @finde = (@dow == 6 || @dow == 0) && (@inicio == '08' || @inicio == '18' || @inicio == '06' || @inicio == '20')

    if @finde
      @out_of = !((@current_time - @schedule_ini_finde) > 0 && (@schedule_fin_finde - @current_time) > 0)
    else
      @out_of = !((@current_time - @schedule_ini_semana) > 0 && (@schedule_fin_semana - @current_time) > 0)
    end

    unless @reserve_to_del.reserve_date >= @current_date
      render json: { result: "Error, can't delete!", status_code: "2" } and return
    end

    if @remaining <= 60 && @user_conected.rol == "estudiante"
      render json: { result: "Error, can't delete!", status_code: "3" } and return
    end

    if @out_of && @user_conected.rol == "estudiante"
      render json: { result: "Can't delete at this moment", status_code: "4" } and return
    end

    Reservation.where(id: params[:id]).destroy_all
    render json: { result: "Data deleted successfully!", status_code: "1" }
  end

  private

  def schedules_params
    params.permit(:suscription_id, :schedule_id, :start_hour, :reserve_date, :room, :duration_hours)
  end

  def active_suscriptions_for_room(user, room_id)
    return Suscription.active_and_valid.where(user_id: user.id) unless user.rol == "estudiante"
    Suscription.active_and_valid.where(user_id: user.id).select do |s|
      suscription_allows_room?(s, room_id)
    end
  end

  def suscription_allows_room?(suscription, room_id)
    return true if suscription.rooms.blank?
    suscription.rooms.split(",").map(&:strip).include?(room_id.to_s)
  end
end
