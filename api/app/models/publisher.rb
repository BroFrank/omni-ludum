class Publisher < ApplicationRecord
  include Auditable
  self.inheritance_column = nil

  has_many :games, dependent: :nullify
  has_many :publisher_texts, dependent: :destroy

  validates :name, presence: true
  validates :type, presence: true, inclusion: { in: PUBLISHER_TYPES::ALL_TYPES }
  validates :slug, presence: true

  before_validation :generate_slug, if: :slug_blank?
  before_validation :normalize_type
  before_validation :check_name_uniqueness, if: :name_changed?
  before_validation :check_slug_uniqueness, if: :slug_changed?

  scope :active, -> { where(is_disabled: false) }
  scope :disabled, -> { where(is_disabled: true) }
  scope :publishers, -> { where(type: PUBLISHER_TYPES::PUBLISHER) }
  scope :developers, -> { where(type: PUBLISHER_TYPES::DEVELOPER) }
  scope :persons, -> { where(type: PUBLISHER_TYPES::PERSON) }

  def publisher?
    type == PUBLISHER_TYPES::PUBLISHER
  end

  def developer?
    type == PUBLISHER_TYPES::DEVELOPER
  end

  def person?
    type == PUBLISHER_TYPES::PERSON
  end

  def disable!
    games.update_all(publisher_id: nil)
    update!(is_disabled: true)
  end

  def restore!
    update!(is_disabled: false)
  end

  def self.find_by_slug!(slug)
    active.find_by!(slug: slug&.downcase)
  end

  def self.find_by_slug(slug)
    active.find_by(slug: slug&.downcase)
  end

  def description_for(locale)
    publisher_texts.find_by(lang_code: locale.to_s.downcase)&.description
  end

  def all_descriptions
    publisher_texts.order(:lang_code)
  end

  private

  def generate_slug
    self.slug = name.parameterize if name.present?
  end

  def slug_blank?
    slug.blank?
  end

  def slug_present?
    slug.present?
  end

  def normalize_type
    self.type = type.upcase if type.present?
  end

  def ensure_slug_presence
    if slug.blank?
      errors.add(:slug, :blank)
    end
  end

  def check_name_uniqueness
    existing = Publisher.active.where("LOWER(name) = LOWER(?)", name)
    existing = existing.where.not(id: id) if id.present?
    if existing.exists?
      errors.add(:name, :taken)
    end
  end

  def check_slug_uniqueness
    existing = Publisher.active.where("LOWER(slug) = LOWER(?)", slug)
    existing = existing.where.not(id: id) if id.present?
    if existing.exists?
      errors.add(:slug, :taken)
    end
  end
end
