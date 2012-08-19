require 'test_helper'

class CraftsControllerTest < ActionController::TestCase
  setup do
    @craft = crafts(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:crafts)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create craft" do
    assert_difference('Craft.count') do
      post :create, craft: @craft.attributes
    end

    assert_redirected_to craft_path(assigns(:craft))
  end

  test "should show craft" do
    get :show, id: @craft
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @craft
    assert_response :success
  end

  test "should update craft" do
    put :update, id: @craft, craft: @craft.attributes
    assert_redirected_to craft_path(assigns(:craft))
  end

  test "should destroy craft" do
    assert_difference('Craft.count', -1) do
      delete :destroy, id: @craft
    end

    assert_redirected_to crafts_path
  end
end
