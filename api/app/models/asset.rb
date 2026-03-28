class Asset < ApplicationRecord
  include Auditable

  belongs_to :game

  validates :game_id, presence: true
  validates :asset_type, presence: true, inclusion: { in: ASSET_TYPES::ALL_TYPES, message: "must be a valid asset type" }
  validates :storage_path, presence: true
  validates :mime_type, presence: true, format: { with: /\A[\w\-]+\/[\w\-\.]+\z/, message: "must be a valid MIME type" }
  validates :file_size, presence: true, numericality: { greater_than: 0, only_integer: true }
  validates :order_index, numericality: { greater_than_or_equal_to: 0, only_integer: true, allow_nil: true }

  scope :active, -> { where(is_disabled: false) }
  scope :disabled, -> { where(is_disabled: true) }
  scope :by_type, ->(type) { where(asset_type: type) }
  scope :ordered, -> { order(:order_index) }

  before_validation :normalize_asset_type

  def cover?
    asset_type == ASSET_TYPES::COVER
  end

  def screenshot?
    asset_type == ASSET_TYPES::SCREENSHOT
  end

  def manual?
    asset_type == ASSET_TYPES::MANUAL
  end

  def type_label
    asset_type&.capitalize
  end

  def disable!
    update!(is_disabled: true)
  end

  def restore!
    update!(is_disabled: false)
  end

  private

  def normalize_asset_type
    self.asset_type = asset_type&.upcase
  end
end
