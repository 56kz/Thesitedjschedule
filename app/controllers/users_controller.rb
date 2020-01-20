class UsersController < ApplicationController
  before_action :authenticate_student!

  def index
    @users = User.all.reverse
    @users_mod =  @users.as_json

    @users.each_with_index  { |item, index|
      @user_id = item.id

      if !Suscription.where(user_id: @user_id, status: true).first.nil?
        @suscription=Suscription.where(user_id: @user_id, status: true).first.id
        @rooms=Suscription.where(user_id: @user_id, status: true).first.rooms
      else
        @suscription=0
        @rooms="0"
      end
      @users_mod[index][:sucription_id]= @suscription
      @users_mod[index][:rooms]= @rooms
    }

    respond_to do |format|
      format.html {}
      format.json { render json: @users_mod }
    end

  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      @student = Student.create(email: @user.email, password: "12345678")
      redirect_to new_suscription_path, notice: "El Usuario fue creado con id: #{@user.id}"
    else
      render :new
    end
  end

  def edit
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])
    if @user.update(user_params)
      redirect_to users_path, notice: "El usuario fue actualizado"
    else
      render :edit
    end
  end

  def destroy
    @user = User.find(params[:id])
    @user.destroy
    redirect_to users_path, notice: "El Usuario fue eliminado"
  end

  private
   def user_params
     params.require(:user).permit(:name, :email, :phone, :rol)
   end
end
