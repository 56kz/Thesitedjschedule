class ApplicationController < ActionController::Base
  respond_to :html, :json

  before_action :set_variable, :authenticate_student!

  def set_variable

    begin
      @user_conected = User.find_by(email: current_student.email)
    rescue => e
      @user_conected = ""
    end
 
  end
  
end
