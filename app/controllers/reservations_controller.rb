class ReservationsController < ApplicationController
  before_action :authenticate_student!
  before_action :require_instructor_or_admin, only: [:new, :create]

  def index
    @user_conected = User.find_by(email: current_student.email)
    if @user_conected&.rol == "estudiante"
      suscription_ids = Suscription.where(user_id: @user_conected.id).pluck(:id)
      @reservations = Reservation
        .where(suscription_id: suscription_ids)
        .order(reserve_date: :desc, start_hour: :desc)
        .limit(500)
    else
      @reservations = Reservation.order(created_at: :desc).limit(1000)
    end
  end

  def new
    @user_conected = User.find_by(email: current_student.email)
    @reservation = Reservation.new
  end

  def create
    @reservation = Reservation.new(reservation_params)
    if @reservation.save
      redirect_to reservations_path, notice: "La reserva fue creada"
    else
      render :new
    end
  end

  private

  def reservation_params
    params.require(:reservation).permit(:suscription_id, :schedule_id)
  end
end
