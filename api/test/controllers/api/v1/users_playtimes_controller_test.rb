require "test_helper"

class Api::V1::UsersPlaytimesControllerTest < ActionDispatch::IntegrationTest
  setup do
    Review.delete_all

    @user = users(:one)
    @user2 = users(:two)
    @game = games(:one)
    @game2 = games(:two)

    @users_playtime = UsersPlaytime.create!(
      user: @user,
      game: @game,
      minutes_regular: 120,
      minutes_100: 360
    )
  end

  test "should get index of all users playtimes" do
    get api_v1_users_playtimes_url
    assert_response :success
    assert_not_nil assigns(:users_playtimes)
  end

  test "should get index of users playtimes for a game" do
    get api_v1_game_users_playtimes_url(game_id: @game.name)
    assert_response :success
    assert_not_nil assigns(:users_playtimes)
    assert_equal @game.id, assigns(:game).id
  end

  test "should return 404 for non-existent game users playtimes" do
    get api_v1_game_users_playtimes_url(game_id: "non-existent-game")
    assert_response :not_found
  end

  test "should get index of users playtimes for a user" do
    get api_v1_user_users_playtimes_url(user_id: @user.slug)
    assert_response :success
    assert_not_nil assigns(:users_playtimes)
    assert_equal @user.id, assigns(:user).id
  end

  test "should return 404 for non-existent user users playtimes" do
    get api_v1_user_users_playtimes_url(user_id: "non-existent-user")
    assert_response :not_found
  end

  test "should show a users playtime" do
    get api_v1_users_playtime_url(@users_playtime)
    assert_response :success
    assert_equal @users_playtime.id, assigns(:users_playtime).id
  end

  test "should return 404 for non-existent users playtime" do
    get api_v1_users_playtime_url(999999)
    assert_response :not_found
  end

  test "should create a users playtime" do
    assert_difference("UsersPlaytime.count", 1) do
      post api_v1_users_playtimes_url, params: {
        users_playtime: {
          user_id: @user2.id,
          game_id: @game2.id,
          minutes_regular: 150,
          minutes_100: 400
        }
      }
    end

    assert_response :created
    assert_equal 150, assigns(:users_playtime).minutes_regular
    assert_equal 400, assigns(:users_playtime).minutes_100
  end

  test "should not create a users playtime without required fields" do
    assert_no_difference("UsersPlaytime.count") do
      post api_v1_users_playtimes_url, params: {
        users_playtime: {
          user_id: @user2.id
        }
      }
    end

    assert_response :unprocessable_entity
    assert_not_nil response.parsed_body["errors"]
  end

  test "should not create duplicate users playtime for same user and game" do
    assert_no_difference("UsersPlaytime.count") do
      post api_v1_users_playtimes_url, params: {
        users_playtime: {
          user_id: @user.id,
          game_id: @game.id,
          minutes_regular: 150,
          minutes_100: 400
        }
      }
    end

    assert_response :unprocessable_entity
  end

  test "should update a users playtime" do
    patch api_v1_users_playtime_url(@users_playtime), params: {
      users_playtime: {
        minutes_regular: 180,
        minutes_100: 450
      }
    }

    assert_response :success
    assert_equal 180, assigns(:users_playtime).minutes_regular
    assert_equal 450, assigns(:users_playtime).minutes_100
  end

  test "should not update a users playtime with negative minutes" do
    patch api_v1_users_playtime_url(@users_playtime), params: {
      users_playtime: {
        minutes_regular: -10
      }
    }

    assert_response :unprocessable_entity
  end

  test "should soft delete a users playtime" do
    delete api_v1_users_playtime_url(@users_playtime)
    assert_response :success

    @users_playtime.reload
    assert @users_playtime.is_disabled
  end

  test "should return paginated results" do
    get api_v1_users_playtimes_url, params: { page: 1, per_page: 10 }
    assert_response :success
    assert assigns(:users_playtimes).count >= 0
  end

  test "should include game and user in response" do
    get api_v1_users_playtime_url(@users_playtime)
    assert_response :success

    json_response = JSON.parse(response.body)
    assert_not_nil json_response["game"]
    assert_not_nil json_response["user"]
  end
end
