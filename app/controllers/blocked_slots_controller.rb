class BlockedSlotsController < ApplicationController
  before_action :authenticate_student!
  before_action :require_instructor_or_admin

  def create
    @user_conected = User.find_by(email: current_student.email)
    room = Room.find_by(id: params[:room_id])

    unless room
      render json: { result: "Sala no encontrada.", status_code: "0" } and return
    end

    if BlockedSlot.exists?(room_id: room.id, block_date: params[:block_date], start_hour: params[:start_hour])
      render json: { result: "Ya existe un bloqueo en ese horario.", status_code: "0" } and return
    end

    if Reservation.exists?(room: room.id.to_s, reserve_date: params[:block_date], start_hour: params[:start_hour])
      render json: { result: "Hay una reserva activa en ese horario. Cancélala primero.", status_code: "0" } and return
    end

    slot = BlockedSlot.create!(
      room_id:        room.id,
      block_date:     params[:block_date],
      start_hour:     params[:start_hour].to_i,
      duration_hours: (params[:duration_hours] || 2).to_i,
      user_id:        @user_conected.id
    )

    render json: {
      result:        "Horario bloqueado.",
      status_code:   "1",
      id:            slot.id,
      start_hour:    slot.start_hour,
      reserve_date:  slot.block_date,
      duration_hours: slot.duration_hours,
      blocked:       true,
      room:          room.id.to_s
    }
  end

  def destroy
    slot = BlockedSlot.find_by(id: params[:id])
    unless slot
      render json: { result: "Bloqueo no encontrado.", status_code: "0" } and return
    end
    slot.destroy
    render json: { result: "Bloqueo eliminado.", status_code: "1" }
  end
end
