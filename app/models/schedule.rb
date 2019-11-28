class Schedule < ApplicationRecord
  belongs_to :room
  has_one :reservation
end
