class Suscription < ApplicationRecord
  belongs_to :user
  has_many :reservations, dependent: :destroy

  enum name: [:MV1, :MV1N2, :MV1N3, :MV2, :MV2N2, :MV2N3, :P1, :P2, :P3, :P4, :P5, :P6, :Bloque, :Demo, :Otro]
  enum hours: [:Dos, :Cuatro, :Doce, :Full]
end
