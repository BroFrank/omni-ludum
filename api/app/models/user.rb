class User < ApplicationRecord
  has_secure_password

  validates :username, presence: true
  validates :username, uniqueness: { case_sensitive: true }
  validates :username, length: { minimum: 3 }
  validates :username, format: { with: /\A[a-zA-Z0-9 ]+\z/, message: "может содержать только буквы, цифры и пробелы" }

  validates :email, presence: true
  validates :email, uniqueness: { case_sensitive: false }
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP, message: "должен быть валидный email" }

  validates :password, length: { minimum: 7, allow_nil: true }
  validates :password, format: { with: /\A.*[A-Z].*\z/, message: "должен содержать заглавную букву", allow_nil: true }
  validates :password, format: { with: /\A.*[a-z].*\z/, message: "должен содержать строчную букву", allow_nil: true }
  validates :password, format: { with: /\A.*[0-9].*\z/, message: "должен содержать цифру", allow_nil: true }
  validates :password, format: { with: /\A.*[!@#$%^&*(),.?":{}|<>].*\z/, message: "должен содержать спецсимвол", allow_nil: true }

  validates :role, presence: true
  validates :role, inclusion: { in: USER_ROLES::ALL_ROLES, message: "неверная роль" }

  validates :slug, uniqueness: { case_sensitive: false }

  before_validation :generate_slug
  before_validation :set_default_role

  scope :active, -> { where(is_disabled: false) }
  scope :disabled, -> { where(is_disabled: true) }

  def admin?
    [ USER_ROLES::SUPER_ADMIN, USER_ROLES::ADMIN ].include?(role)
  end

  def moderator?
    [ USER_ROLES::SUPER_ADMIN, USER_ROLES::ADMIN, USER_ROLES::MODERATOR ].include?(role)
  end

  def regular?
    role == USER_ROLES::REGULAR
  end

  def self.find_by_slug!(slug)
    active.find_by!(slug: slug)
  end

  def self.find_by_slug(slug)
    active.find_by(slug: slug)
  end

  private

  def generate_slug
    return unless username.present? && slug.blank?

    self.slug = username.downcase.gsub(/\s+/, "_").gsub(/[^a-z0-9_]/, "")
  end

  def set_default_role
    self.role ||= USER_ROLES::REGULAR
  end
end
