require 'test_helper'

class CityStatesControllerTest < ActionController::TestCase
  setup do
    @city_state = city_states(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:city_states)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create city_state" do
    assert_difference('CityState.count') do
      post :create, city_state: @city_state.attributes
    end

    assert_redirected_to city_state_path(assigns(:city_state))
  end

  test "should show city_state" do
    get :show, id: @city_state
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @city_state
    assert_response :success
  end

  test "should update city_state" do
    put :update, id: @city_state, city_state: @city_state.attributes
    assert_redirected_to city_state_path(assigns(:city_state))
  end

  test "should destroy city_state" do
    assert_difference('CityState.count', -1) do
      delete :destroy, id: @city_state
    end

    assert_redirected_to city_states_path
  end
end
