class Genre < ApplicationRecord
  has_many :genre_texts, dependent: :destroy
  has_many :game_genres, dependent: :destroy
  has_many :games, through: :game_genres

  validates :name, presence: true
  validates :slug, presence: true

  before_validation :generate_slug, if: :slug_blank?
  before_validation :check_name_uniqueness, if: :name_changed?
  before_validation :check_slug_uniqueness, if: :slug_changed?

  scope :active, -> { where(is_disabled: false) }
  scope :disabled, -> { where(is_disabled: true) }

  def disable!
    game_genres.update_all(is_disabled: true)
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
    genre_texts.find_by(lang_code: locale.to_s.downcase)&.description
  end

  def all_descriptions
    genre_texts.order(:lang_code)
  end

  private

  def generate_slug
    self.slug = name.parameterize if name.present?
  end

  def slug_blank?
    slug.blank?
  end

  def check_name_uniqueness
    existing = Genre.active.where("LOWER(name) = LOWER(?)", name)
    existing = existing.where.not(id: id) if id.present?
    if existing.exists?
      errors.add(:name, :taken)
    end
  end

  def check_slug_uniqueness
    existing = Genre.active.where("LOWER(slug) = LOWER(?)", slug)
    existing = existing.where.not(id: id) if id.present?
    if existing.exists?
      errors.add(:slug, :taken)
    end
  end
end
