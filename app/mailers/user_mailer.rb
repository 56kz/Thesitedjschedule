# frozen_string_literal: true

class UserMailer < ApplicationMailer
  def welcome_email(user)
    @user = user
    @login_url = new_student_session_url
    mail(to: @user.email, subject: "Bienvenido a The Site DeeJay Academy")
  end
end
