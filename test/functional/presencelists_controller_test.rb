require 'test_helper'

class PresencelistsControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:presencelists)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create presencelist" do
    assert_difference('Presencelist.count') do
      post :create, :presencelist => { }
    end

    assert_redirected_to presencelist_path(assigns(:presencelist))
  end

  test "should show presencelist" do
    get :show, :id => presencelists(:one).to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => presencelists(:one).to_param
    assert_response :success
  end

  test "should update presencelist" do
    put :update, :id => presencelists(:one).to_param, :presencelist => { }
    assert_redirected_to presencelist_path(assigns(:presencelist))
  end

  test "should destroy presencelist" do
    assert_difference('Presencelist.count', -1) do
      delete :destroy, :id => presencelists(:one).to_param
    end

    assert_redirected_to presencelists_path
  end
end
