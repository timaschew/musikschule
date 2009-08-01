require 'test_helper'

class PupilsControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:pupils)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create pupil" do
    assert_difference('Pupil.count') do
      post :create, :pupil => { }
    end

    assert_redirected_to pupil_path(assigns(:pupil))
  end

  test "should show pupil" do
    get :show, :id => pupils(:one).to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => pupils(:one).to_param
    assert_response :success
  end

  test "should update pupil" do
    put :update, :id => pupils(:one).to_param, :pupil => { }
    assert_redirected_to pupil_path(assigns(:pupil))
  end

  test "should destroy pupil" do
    assert_difference('Pupil.count', -1) do
      delete :destroy, :id => pupils(:one).to_param
    end

    assert_redirected_to pupils_path
  end
end
