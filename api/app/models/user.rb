class User < ApplicationRecord
  include Auditable

  has_secure_password

  validates :username, presence: true
  validates :username, uniqueness: { case_sensitive: false }
  validates :username, length: { minimum: 3 }
  validates :username, format: { with: /\A[a-zA-Z0-9 ]+\z/, message: :invalid }

  validates :email, presence: true
  validates :email, uniqueness: { case_sensitive: false }
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP, message: :invalid }

  validates :password, length: { minimum: 7, allow_nil: true }
  validates :password, format: { with: /\A.*[A-Z].*\z/, message: :invalid_password_format, allow_nil: true }
  validates :password, format: { with: /\A.*[a-z].*\z/, message: :invalid_password_format, allow_nil: true }
  validates :password, format: { with: /\A.*[0-9].*\z/, message: :invalid_password_format, allow_nil: true }
  validates :password, format: { with: /\A.*[!@#$%^&*(),.?":{}|<>].*\z/, message: :invalid_password_format, allow_nil: true }

  validates :role, presence: true
  validates :role, inclusion: { in: USER_ROLES::ALL_ROLES, message: :invalid }

  validates :theme, presence: true
  validates :theme, inclusion: { in: USER_THEMES::ALL_THEMES, message: :invalid }

  validates :locale, presence: true
  validates :locale, inclusion: { in: USER_LOCALES::ALL_LOCALES, message: :invalid }

  validates :slug, uniqueness: { case_sensitive: false }

  before_validation :generate_slug
  before_validation :set_default_role
  before_validation :set_default_theme
  before_validation :set_default_locale

  scope :active, -> { where(is_disabled: false) }
  scope :disabled, -> { where(is_disabled: true) }
  scope :with_theme, ->(theme) { where(theme: theme) }
  scope :with_locale, ->(locale) { where(locale: locale) }

  has_many :reviews, dependent: :nullify
  has_many :users_playtimes, dependent: :nullify

  def admin?
    [ USER_ROLES::SUPER_ADMIN, USER_ROLES::ADMIN ].include?(role)
  end

  def moderator?
    [ USER_ROLES::SUPER_ADMIN, USER_ROLES::ADMIN, USER_ROLES::MODERATOR ].include?(role)
  end

  def regular?
    role == USER_ROLES::REGULAR
  end

  def light_theme?
    theme == USER_THEMES::LIGHT
  end

  def dark_theme?
    theme == USER_THEMES::DARK
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

  def set_default_theme
    self.theme ||= USER_THEMES::LIGHT
  end

  def set_default_locale
    self.locale ||= USER_LOCALES::ENGLISH
  end
end
