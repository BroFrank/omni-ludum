class AuditLog < ApplicationRecord
  belongs_to :user, optional: true

  validates :action, presence: true, inclusion: { in: AUDIT_ACTIONS::ALL_ACTIONS, message: "must be CREATE, UPDATE, or DELETE" }
  validates :table_name, presence: true
  validates :record_id, presence: true

  scope :by_action, ->(action) { where(action: action) }
  scope :by_table, ->(table_name) { where(table_name: table_name) }
  scope :by_user, ->(user_id) { where(user_id: user_id) }
  scope :recent, -> { order(created_at: :desc) }
end
