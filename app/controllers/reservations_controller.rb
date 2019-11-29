class ReservationsController < ApplicationController
  def index
    @reservations = Reservation.all
  end

  def new
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
