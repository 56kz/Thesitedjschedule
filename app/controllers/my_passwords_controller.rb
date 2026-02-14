# frozen_string_literal: true

class MyPasswordsController < ApplicationController
  before_action :authenticate_student!

  def edit
    @minimum_password_length = Devise.password_length.min
  end

  def update
    unless current_student.valid_password?(password_params[:current_password])
      current_student.errors.add(:current_password, "no es correcta")
      return render :edit
    end
    if current_student.update(password_params.except(:current_password))
      bypass_sign_in(current_student)
      redirect_to root_path, notice: "Tu contraseña fue actualizada."
    else
      render :edit
    end
  end

  private

  def password_params
    params.require(:student).permit(:current_password, :password, :password_confirmation)
  end
end
