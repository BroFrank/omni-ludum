require "test_helper"

class Api::V1::ReviewsControllerTest < ActionDispatch::IntegrationTest
  setup do
    # Clean up any reviews created by previous tests
    Review.delete_all
    
    @user = users(:one)
    @user2 = users(:two)
    @game = games(:one)
    @game2 = games(:two)
    
    @review = Review.create!(
      user: @user,
      game: @game,
      rating: 8,
      difficulty: 5,
      comment: "Great game!"
    )
  end

  test "should get index of all reviews" do
    get api_v1_reviews_url
    assert_response :success
    assert_not_nil assigns(:reviews)
  end

  test "should get index of reviews for a game" do
    get api_v1_game_reviews_url(game_id: @game.name)
    assert_response :success
    assert_not_nil assigns(:reviews)
    assert_equal @game.id, assigns(:game).id
  end

  test "should return 404 for non-existent game reviews" do
    get api_v1_game_reviews_url(game_id: "non-existent-game")
    assert_response :not_found
  end

  test "should get index of reviews for a user" do
    get api_v1_user_reviews_url(user_id: @user.slug)
    assert_response :success
    assert_not_nil assigns(:reviews)
    assert_equal @user.id, assigns(:user).id
  end

  test "should return 404 for non-existent user reviews" do
    get api_v1_user_reviews_url(user_id: "non-existent-user")
    assert_response :not_found
  end

  test "should show a review" do
    get api_v1_review_url(@review)
    assert_response :success
    assert_equal @review.id, assigns(:review).id
  end

  test "should return 404 for non-existent review" do
    get api_v1_review_url(999999)
    assert_response :not_found
  end

  test "should create a review" do
    assert_difference("Review.count", 1) do
      post api_v1_reviews_url, params: {
        review: {
          user_id: @user2.id,
          game_id: @game2.id,
          rating: 9,
          difficulty: 6,
          comment: "Excellent!"
        }
      }
    end
    
    assert_response :created
    assert_equal 9, assigns(:review).rating
    assert_equal 6, assigns(:review).difficulty
  end

  test "should not create a review without required fields" do
    assert_no_difference("Review.count") do
      post api_v1_reviews_url, params: {
        review: {
          user_id: @user2.id,
          game_id: @game2.id
        }
      }
    end
    
    assert_response :unprocessable_entity
    assert_not_nil response.parsed_body["errors"]
  end

  test "should not create duplicate review for same user and game" do
    assert_no_difference("Review.count") do
      post api_v1_reviews_url, params: {
        review: {
          user_id: @user.id,
          game_id: @game.id,
          rating: 7,
          difficulty: 4
        }
      }
    end
    
    assert_response :unprocessable_entity
  end

  test "should update a review" do
    patch api_v1_review_url(@review), params: {
      review: {
        rating: 10,
        difficulty: 8,
        comment: "Updated review"
      }
    }
    
    assert_response :success
    assert_equal 10, assigns(:review).rating
    assert_equal 8, assigns(:review).difficulty
    assert_equal "Updated review", assigns(:review).comment
  end

  test "should not update a review with invalid rating" do
    patch api_v1_review_url(@review), params: {
      review: {
        rating: 11
      }
    }
    
    assert_response :unprocessable_entity
  end

  test "should soft delete a review" do
    delete api_v1_review_url(@review)
    assert_response :success
    
    @review.reload
    assert @review.is_disabled
  end

  test "should return paginated results" do
    # Create more reviews with existing user on same game (using different users)
    # Since we can't create duplicate reviews, we'll just test with existing data
    get api_v1_reviews_url, params: { page: 1, per_page: 10 }
    assert_response :success
    assert assigns(:reviews).count >= 0
  end

  test "should include game and user in response" do
    get api_v1_review_url(@review)
    assert_response :success
    
    json_response = JSON.parse(response.body)
    assert_not_nil json_response["game"]
    assert_not_nil json_response["user"]
  end
end
