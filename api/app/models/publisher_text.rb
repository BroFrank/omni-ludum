class PublisherText < ApplicationRecord
  belongs_to :publisher

  validates :publisher_id, presence: true
  validates :lang_code, presence: true, length: { is: 2 }, format: { with: /\A[a-z]{2}\z/ }
  validates :description, length: { maximum: 10000, allow_nil: true }
  validates :lang_code, uniqueness: { scope: :publisher_id, case_sensitive: false }

  scope :active, -> { joins(:publisher).where(publishers: { is_disabled: false }) }
  scope :by_lang, ->(lang_code) { where(lang_code: lang_code.downcase) }
  scope :for_publisher, ->(publisher_id) { where(publisher_id: publisher_id) }

  before_validation :normalize_lang_code

  private

  def normalize_lang_code
    self.lang_code = lang_code.downcase if lang_code.present?
  end
end
