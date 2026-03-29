class GameGenre < ApplicationRecord
  include Auditable

  belongs_to :game
  belongs_to :genre

  validates :genre_id, uniqueness: { scope: :game_id, conditions: -> { where(is_disabled: false) } }

  scope :active, -> { where(is_disabled: false) }
  scope :disabled, -> { where(is_disabled: true) }

  def disable!
    update!(is_disabled: true)
  end

  def restore!
    update!(is_disabled: false)
  end
end
