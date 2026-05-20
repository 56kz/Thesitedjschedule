class BlockedSlot < ApplicationRecord
  belongs_to :room
  belongs_to :user

  validates :start_hour, :block_date, :duration_hours, presence: true
  validates :start_hour, uniqueness: { scope: [:room_id, :block_date] }
end
