class Schedule < ApplicationRecord
  belongs_to :room, dependent: :destroy
  has_one :reservation, dependent: :destroy
end
