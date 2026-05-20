class Suscription < ApplicationRecord
  belongs_to :user
  has_many :reservations, dependent: :destroy

  enum :name, [:MV1, :MV1N2, :MV2, :MV2N2, :MV3, :MV3N2, :P1, :P2, :P3, :P4, :P5, :Bloque, :Demo, :Otro]
  # IMPORTANTE: no reordenar — los índices enteros están en la BD.
  # Nuevos valores siempre se agregan al final.
  enum :hours, [:Dos, :Cuatro, :Doce, :Full, :Diez, :Una, :Cinco]

  HOURS_VALUE = {
    "Dos"    => 2,
    "Cuatro" => 4,
    "Doce"   => 12,
    "Full"   => 24,
    "Diez"   => 10,
    "Una"    => 1,
    "Cinco"  => 5
  }.freeze

  before_create :set_default_expiry

  scope :active_and_valid, -> {
    where(status: true)
      .where("expires_at IS NULL OR expires_at >= ?", Date.current)
  }

  def hours_total
    HOURS_VALUE[hours] || 0
  end

  def hours_used
    reservations.sum(:duration_hours)
  end

  def hours_remaining
    hours_total - hours_used
  end

  def expired?
    expires_at.present? && expires_at < Date.current
  end

  private

  def set_default_expiry
    self.expires_at ||= Date.current + 6.months
  end
end
