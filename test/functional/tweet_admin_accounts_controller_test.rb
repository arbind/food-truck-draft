require 'test_helper'

class TweetAdminAccountsControllerTest < ActionController::TestCase
  setup do
    @tweet_admin_account = tweet_admin_accounts(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:tweet_admin_accounts)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create tweet_admin_account" do
    assert_difference('TweetAdminAccount.count') do
      post :create, tweet_admin_account: @tweet_admin_account.attributes
    end

    assert_redirected_to tweet_admin_account_path(assigns(:tweet_admin_account))
  end

  test "should show tweet_admin_account" do
    get :show, id: @tweet_admin_account
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @tweet_admin_account
    assert_response :success
  end

  test "should update tweet_admin_account" do
    put :update, id: @tweet_admin_account, tweet_admin_account: @tweet_admin_account.attributes
    assert_redirected_to tweet_admin_account_path(assigns(:tweet_admin_account))
  end

  test "should destroy tweet_admin_account" do
    assert_difference('TweetAdminAccount.count', -1) do
      delete :destroy, id: @tweet_admin_account
    end

    assert_redirected_to tweet_admin_accounts_path
  end
end
