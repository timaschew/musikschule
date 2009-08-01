require 'test_helper'

class CourselistsControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:courselists)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create courselist" do
    assert_difference('Courselist.count') do
      post :create, :courselist => { }
    end

    assert_redirected_to courselist_path(assigns(:courselist))
  end

  test "should show courselist" do
    get :show, :id => courselists(:one).to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => courselists(:one).to_param
    assert_response :success
  end

  test "should update courselist" do
    put :update, :id => courselists(:one).to_param, :courselist => { }
    assert_redirected_to courselist_path(assigns(:courselist))
  end

  test "should destroy courselist" do
    assert_difference('Courselist.count', -1) do
      delete :destroy, :id => courselists(:one).to_param
    end

    assert_redirected_to courselists_path
  end
end
