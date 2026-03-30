class AccessTokenBlacklist < ApplicationRecord
  belongs_to :user, optional: true

  validates :jti, presence: true
  validates :expires_at, presence: true

  scope :active, -> { where('expires_at > ?', Time.current) }
  scope :expired, -> { where('expires_at <= ?', Time.current) }

  def self.add(jti, expires_at, reason: nil, user_id: nil)
    create!(jti: jti, expires_at: expires_at, reason: reason, user_id: user_id)
  rescue ActiveRecord::RecordNotUnique
    false
  end

  def self.revoked?(jti)
    active.exists?(jti: jti)
  end

  def self.cleanup_old(days_old: 7)
    expired.where('access_token_blacklists.created_at < ?', days_old.days.ago).destroy_all
  end
end
