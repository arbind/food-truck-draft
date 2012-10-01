require 'test_helper'

class TweetStreamAccountsControllerTest < ActionController::TestCase
  setup do
    @tweet_stream_account = tweet_stream_accounts(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:tweet_stream_accounts)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create tweet_stream_account" do
    assert_difference('TweetStreamAccount.count') do
      post :create, tweet_stream_account: @tweet_stream_account.attributes
    end

    assert_redirected_to tweet_stream_account_path(assigns(:tweet_stream_account))
  end

  test "should show tweet_stream_account" do
    get :show, id: @tweet_stream_account
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @tweet_stream_account
    assert_response :success
  end

  test "should update tweet_stream_account" do
    put :update, id: @tweet_stream_account, tweet_stream_account: @tweet_stream_account.attributes
    assert_redirected_to tweet_stream_account_path(assigns(:tweet_stream_account))
  end

  test "should destroy tweet_stream_account" do
    assert_difference('TweetStreamAccount.count', -1) do
      delete :destroy, id: @tweet_stream_account
    end

    assert_redirected_to tweet_stream_accounts_path
  end
end
