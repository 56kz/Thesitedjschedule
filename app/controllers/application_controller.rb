class ApplicationController < ActionController::Base
  respond_to :html, :json

  before_action :set_variable, :authenticate_student!

  def set_variable
    @user_conected = User.find_by(email: current_student.email)
  rescue StandardError
    @user_conected = nil
  end

  def require_instructor_or_admin
    return if @user_conected.try(:rol).in?(%w[instructor admin])
    redirect_to root_path, alert: "No autorizado"
  end
end
