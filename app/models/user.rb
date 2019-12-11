class User < ApplicationRecord
  has_many :suscriptions
  validates :name, :email, :phone, :rol, presence: true

  enum rol: [:estudiante, :instructor, :admin]
end
