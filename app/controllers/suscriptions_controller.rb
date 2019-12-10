class SuscriptionsController < ApplicationController
  before_action :authenticate_student!

  def index
    @suscriptions = Suscription.all
  end

  def new
    @suscription = Suscription.new
  end

  def create
    @suscription = Suscription.new(suscription_params)
    if @suscription.save
      redirect_to suscriptions_path, notice: "La Suscripcion fue creada"
    else
      render :new
    end
  end

  def edit
    @suscription = Suscription.find(params[:id])
  end

  def update
    @suscription = Suscription.find(params[:id])
    if @suscription.update(suscription_params)
      redirect_to suscriptions_path, notice: "La Suscripción fue actualizada"
    else
      render :edit
    end
  end

  def destroy
    suscription = Suscription.find(params[:id])
    suscription.destroy

    redirect_to suscriptions_path, notice: "La Suscriprión fue eliminada"
  end

  private
   def suscription_params
     params.require(:suscription).permit(:name, :status, :user_id, :hours, :rooms, :observations)
   end
end
