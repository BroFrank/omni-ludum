class Platform < ApplicationRecord
  include Auditable

  has_many :games, dependent: :nullify

  validates :name, presence: true
  validates :slug, presence: true, uniqueness: { case_sensitive: false }
  validates :slug, format: { with: /\A[a-z0-9\-_]+\z/ }

  scope :active, -> { where(is_disabled: false) }
  scope :disabled, -> { where(is_disabled: true) }

  before_validation :generate_slug, if: -> { slug.blank? }

  after_save :invalidate_active_ordered_cache
  after_destroy :invalidate_active_ordered_cache

  def self.active_ordered
    Rails.cache.fetch("platforms/v1/active_ordered", expires_in: 1.hour) do
      active.order(:name).to_a
    end
  end

  def self.find_by_slug!(slug)
    active.find_by!(slug: slug)
  end

  def self.find_by_slug(slug)
    active.find_by(slug: slug)
  end

  private

  def slug_blank?
    slug.blank?
  end

  def generate_slug
    return if name.blank?

    self.slug = name.downcase
               .gsub(/\s+/, "-")
               .gsub(/[^a-z0-9\-]/, "")
  end

  def invalidate_active_ordered_cache
    Rails.cache.delete("platforms/v1/active_ordered")
  end
end
