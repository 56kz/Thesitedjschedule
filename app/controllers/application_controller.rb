class ApplicationController < ActionController::Base
  respond_to :html, :json

  before_action :set_variable, :authenticate_student!

  def set_variable
      @user_conected = User.find_by(email: current_student.email)
  end
  
end
