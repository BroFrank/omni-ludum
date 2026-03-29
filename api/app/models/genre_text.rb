class GenreText < ApplicationRecord
  include Auditable

  belongs_to :genre

  validates :lang_code, presence: true, length: { is: 2 }, format: { with: /\A[a-z]{2}\z/ }
  validates :description, length: { maximum: 10000, allow_nil: true }
  validates :lang_code, uniqueness: { scope: :genre_id, case_sensitive: false }

  scope :active, -> { joins(:genre).where(genres: { is_disabled: false }) }
  scope :by_lang, ->(lang_code) { where(lang_code: lang_code.downcase) }
  scope :for_genre, ->(genre_id) { where(genre_id: genre_id) }

  before_validation :normalize_lang_code

  private

  def normalize_lang_code
    self.lang_code = lang_code.downcase if lang_code.present?
  end
end
