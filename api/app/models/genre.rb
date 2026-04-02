class Genre < ApplicationRecord
  include Auditable

  has_many :genre_texts, dependent: :destroy
  has_many :game_genres, dependent: :destroy
  has_many :games, through: :game_genres

  validates :name, presence: true
  validates :slug, presence: true

  before_validation :generate_slug, if: :slug_blank?
  before_validation :check_name_uniqueness, if: :name_changed?
  before_validation :check_slug_uniqueness, if: :slug_changed?

  after_save :invalidate_active_ordered_cache
  after_destroy :invalidate_active_ordered_cache

  scope :active, -> { where(is_disabled: false) }
  scope :disabled, -> { where(is_disabled: true) }

  def self.active_ordered
    Rails.cache.fetch("genres/v1/active_ordered", expires_in: 1.hour) do
      active.order(:name).to_a
    end
  end

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

  private

  def invalidate_active_ordered_cache
    Rails.cache.delete("genres/v1/active_ordered")
  end
end
