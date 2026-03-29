class Link < ApplicationRecord
  include Auditable

  belongs_to :game

  validates :link_type, presence: true, inclusion: { in: LINK_TYPES::ALL_TYPES, message: "must be a valid link type" }
  validates :url, presence: true, format: { with: URI::DEFAULT_PARSER.make_regexp, message: "must be a valid URL" }
  validates :title, presence: true, length: { minimum: 1, maximum: 255 }

  scope :active, -> { where(is_disabled: false) }
  scope :disabled, -> { where(is_disabled: true) }
  scope :by_type, ->(type) { where(link_type: type) }

  before_validation :normalize_link_type

  def trailer?
    link_type == LINK_TYPES::TRAILER
  end

  def longplay?
    link_type == LINK_TYPES::LONGPLAY
  end

  def speedrun?
    link_type == LINK_TYPES::SPEEDRUN
  end

  def other?
    link_type == LINK_TYPES::OTHER
  end

  def type_label
    link_type&.capitalize
  end

  def disable!
    update!(is_disabled: true)
  end

  def restore!
    update!(is_disabled: false)
  end

  private

  def normalize_link_type
    self.link_type = link_type&.upcase
  end
end
