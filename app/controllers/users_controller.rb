class UsersController < ApplicationController
  before_action :authenticate_student!

  def index
    @user_conected = User.find_by(email: current_student.email)
    @users = User.order(created_at: :desc).limit(1000)
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
    @user_conected = User.find_by(email: current_student.email)
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      @user.update(email: @user.email.downcase)
      @student = Student.create(email: @user.email, password: "12345678")
      redirect_to new_suscription_path, notice: "#{@user.name} ingresó al sistema"
    else
      render :new
    end
  end

  def edit
    @user_conected = User.find_by(email: current_student.email)
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
    @student = Student.find(params[:id])
    @student.destroy
    redirect_to users_path, notice: "#{@user.name} salió del sistema"
  end

  private
   def user_params
     params.require(:user).permit(:name, :email, :phone, :rol)
   end
end
