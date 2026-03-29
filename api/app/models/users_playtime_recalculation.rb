class UsersPlaytimeRecalculation < ApplicationRecord
  belongs_to :game

  validates :status, presence: true, inclusion: { in: %w[pending processing completed failed] }

  scope :pending, -> { where(status: "pending") }
  scope :processing, -> { where(status: "processing") }
  scope :completed, -> { where(status: "completed") }
  scope :failed, -> { where(status: "failed") }
  scope :for_processing, -> { where(status: "pending").where("scheduled_at <= ?", Time.current) }

  STATUS_PENDING = "pending"
  STATUS_PROCESSING = "processing"
  STATUS_COMPLETED = "completed"
  STATUS_FAILED = "failed"
end
