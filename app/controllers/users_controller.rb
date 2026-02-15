class UsersController < ApplicationController
  before_action :authenticate_student!
  before_action :require_instructor_or_admin

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
      default_password = ENV.fetch("DEFAULT_STUDENT_PASSWORD", "12345678")
      @student = Student.create(email: @user.email, password: default_password)
      UserMailer.welcome_email(@user).deliver_later
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
    @student = Student.find_by(email: @user.email)
    @user.destroy
    @student&.destroy
    redirect_to users_path, notice: "#{@user.name} salió del sistema"
  end

  def edit_password
    @user = User.find(params[:id])
  end

  def update_password
    @user = User.find(params[:id])
    @student = Student.find_by(email: @user.email)
    unless @student
      redirect_to users_path, alert: "No existe cuenta de estudiante para este usuario."
      return
    end
    if @student.update(password: params[:password], password_confirmation: params[:password_confirmation])
      redirect_to users_path, notice: "Contraseña de #{@user.name} actualizada."
    else
      render :edit_password, status: :unprocessable_entity
    end
  end

  def send_reset_password_instructions
    @user = User.find(params[:id])
    @student = Student.find_by(email: @user.email)
    unless @student
      redirect_to users_path, alert: "No existe cuenta de estudiante para este usuario."
      return
    end
    @student.send_reset_password_instructions
    redirect_to users_path, notice: "Se enviaron las instrucciones al correo de #{@user.email}."
  end

  private

  def user_params
    params.require(:user).permit(:name, :email, :phone, :rol)
  end
end
