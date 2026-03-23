class Game < ApplicationRecord
  belongs_to :base_game, class_name: "Game", optional: true
  has_many :dlcs, class_name: "Game", foreign_key: :base_game_id

  validates :name, presence: true
  validates :name, uniqueness: { case_sensitive: false }
  validates :release_year, numericality: { only_integer: true, allow_nil: true }
  validates :release_year, inclusion: { in: 1970..2100, allow_nil: true }
  validates :rating_avg, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 10, allow_nil: true }
  validates :difficulty_avg, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 10, allow_nil: true }
  validates :playtime_avg, numericality: { greater_than_or_equal_to: 0, allow_nil: true }
  validates :playtime_100_avg, numericality: { greater_than_or_equal_to: 0, allow_nil: true }

  scope :active, -> { where(is_disabled: false) }
  scope :disabled, -> { where(is_disabled: true) }
  scope :with_base_game, -> { where.not(base_game_id: nil) }
  scope :without_base_game, -> { where(base_game_id: nil) }
  scope :dlcs, -> { where(is_dlc: true) }
  scope :mods, -> { where(is_mod: true) }
  scope :original_games, -> { where(is_dlc: false, is_mod: false) }

  def dlc?
    is_dlc
  end

  def mod?
    is_mod
  end

  def original_game?
    !is_dlc && !is_mod
  end

  def base_game
    super || self
  end

  def self.find_by_name!(name)
    active.find_by!(name: name)
  end

  def self.find_by_name(name)
    active.find_by(name: name)
  end
end
