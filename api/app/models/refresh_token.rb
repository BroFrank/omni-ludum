class RefreshToken < ApplicationRecord
  belongs_to :user, dependent: :destroy

  validates :user_id, presence: true
  validates :token_digest, presence: true
  validates :expires_at, presence: true

  scope :active, -> { where(revoked_at: nil).where('expires_at > ?', Time.current) }
  scope :expired, -> { where('expires_at <= ?', Time.current) }
  scope :revoked, -> { where.not(revoked_at: nil) }

  def active?
    !revoked? && !expired?
  end

  def revoked?
    revoked_at.present?
  end

  def expired?
    expires_at <= Time.current
  end

  def revoke!
    update!(revoked_at: Time.current)
  end
end
