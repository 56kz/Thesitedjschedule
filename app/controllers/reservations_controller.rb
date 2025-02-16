class ReservationsController < ApplicationController
  before_action :authenticate_student!

  def index
    @user_conected = User.find_by(email: current_student.email)
    @reservations = Reservation.order(created_at: :desc).limit(1000)
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
