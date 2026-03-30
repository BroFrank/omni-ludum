class ReviewDeleteService
  class ReviewDeleteError < ApplicationService::BaseError; end

  def self.call(review, current_user: nil)
    new(review, current_user).delete
  end

  def initialize(review, current_user = nil)
    @review = review
    @current_user = current_user
  end

  def delete
    raise ReviewDeleteError, "Review is already disabled" if @review.is_disabled?

    ActiveRecord::Base.transaction do
      old_values = review_attributes

      @review.update!(is_disabled: true)

      AuditLogService.log_delete(
        user_id: @current_user&.id,
        table_name: "reviews",
        record_id: @review.id,
        old_values: old_values
      )

      GameRatingRecalculationJob.perform_later(@review.game_id)
    end

    @review
  rescue ActiveRecord::RecordInvalid => e
    raise ReviewDeleteError, e.message
  end

  private

  def review_attributes
    {
      "user_id" => @review.user_id,
      "game_id" => @review.game_id,
      "rating" => @review.rating,
      "difficulty" => @review.difficulty,
      "comment" => @review.comment,
      "is_disabled" => @review.is_disabled
    }
  end
end
