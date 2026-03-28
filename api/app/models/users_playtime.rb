class UsersPlaytime < ApplicationRecord
  include Auditable

  belongs_to :user
  belongs_to :game

  validates :user_id, presence: true
  validates :game_id, presence: true
  validates :minutes_regular, numericality: { greater_than_or_equal_to: 0, allow_nil: true }
  validates :minutes_100, numericality: { greater_than_or_equal_to: 0, allow_nil: true }

  validate :unique_active_playtime_per_user_game

  scope :active, -> { where(is_disabled: false) }
  scope :disabled, -> { where(is_disabled: true) }

  after_create :enqueue_game_recalculation
  after_update :enqueue_game_recalculation_if_changed
  after_destroy :enqueue_game_recalculation

  def self.find_by_user_and_game(user_id, game_id)
    active.find_by(user_id: user_id, game_id: game_id)
  end

  private

  def unique_active_playtime_per_user_game
    return if is_disabled

    existing_playtime = UsersPlaytime.active
      .where(user_id: user_id, game_id: game_id)
      .where.not(id: id)
      .exists?

    if existing_playtime
      errors.add(:user_id, "has already recorded playtime for this game")
    end
  end

  def enqueue_game_recalculation
    UsersPlaytimeRecalculationService.enqueue(game_id)
  end

  def enqueue_game_recalculation_if_changed
    return unless saved_change_to_minutes_regular? || saved_change_to_minutes_100? || saved_change_to_is_disabled?

    enqueue_game_recalculation
  end
end
