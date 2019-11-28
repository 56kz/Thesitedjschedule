class User < ApplicationRecord
  has_many :suscriptions

  enum rol: [:student, :teacher, :admin]
end
