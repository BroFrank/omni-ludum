class Review < ApplicationRecord
  belongs_to :user
  belongs_to :game

  validates :user_id, presence: true
  validates :game_id, presence: true
  validates :rating, presence: true, inclusion: { in: 0..10, message: 'must be between 0 and 10' }
  validates :difficulty, presence: true, inclusion: { in: 0..10, message: 'must be between 0 and 10' }
  validates :comment, length: { maximum: 10000, allow_blank: true }

  validate :unique_active_review_per_user_game

  scope :active, -> { where(is_disabled: false) }
  scope :disabled, -> { where(is_disabled: true) }

  after_create :enqueue_game_recalculation
  after_update :enqueue_game_recalculation_if_rating_changed
  after_destroy :enqueue_game_recalculation

  private

  def unique_active_review_per_user_game
    return if is_disabled
    
    existing_review = Review.active
      .where(user_id: user_id, game_id: game_id)
      .where.not(id: id)
      .exists?
    
    if existing_review
      errors.add(:user_id, 'has already reviewed this game')
    end
  end

  def enqueue_game_recalculation
    GameRatingRecalculationService.enqueue(game_id)
    GameRatingRecalculationJob.perform_later(game_id)
  end

  def enqueue_game_recalculation_if_rating_changed
    if saved_change_to_rating? || saved_change_to_difficulty? || saved_change_to_is_disabled?
      enqueue_game_recalculation
    end
  end
end
