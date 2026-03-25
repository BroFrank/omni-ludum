module Api
  module V1
    class ReviewsController < BaseController
      before_action :set_game, only: [ :index, :create ]
      before_action :set_user, only: [ :index ]
      before_action :set_review, only: [ :show, :update, :destroy ]

      def index
        @reviews = if @game
                     @game.reviews.active.order(created_at: :desc)
        elsif @user
                     @user.reviews.active.includes(:game).order(created_at: :desc)
        else
                     Review.active.includes(:game, :user).order(created_at: :desc)
        end

        @reviews = @reviews.page(params[:page]).per(params[:per_page] || 20)

        render json: @reviews, include: [ :game, :user ], status: :ok
      end

      def show
        render json: @review, include: [ :game, :user ], status: :ok
      end

      def create
        @review = Review.new(review_params)

        if @review.save
          render json: @review, include: [ :game, :user ], status: :created
        else
          render json: { errors: @review.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def update
        if @review.update(review_params)
          render json: @review, include: [ :game, :user ], status: :ok
        else
          render json: { errors: @review.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def destroy
        @review.update!(is_disabled: true)
        render json: { message: "Review successfully deleted" }, status: :ok
      end

      private

      def set_game
        if params[:game_id]
          @game = Game.find_by_name(params[:game_id])
          render json: { error: "Game not found" }, status: :not_found unless @game
        end
      end

      def set_user
        if params[:user_id]
          @user = User.find_by_slug(params[:user_id])
          render json: { error: "User not found" }, status: :not_found unless @user
        end
      end

      def set_review
        @review = Review.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: "Review not found" }, status: :not_found
      end

      def review_params
        params.require(:review).permit(:user_id, :game_id, :rating, :difficulty, :comment)
      end
    end
  end
end
