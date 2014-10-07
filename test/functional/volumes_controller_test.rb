require 'test_helper'

class VolumesControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:volumes)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create volume" do
    assert_difference('Volume.count') do
      post :create, :volume => { }
    end

    assert_redirected_to volume_path(assigns(:volume))
  end

  test "should show volume" do
    get :show, :id => volumes(:volume_one).to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => volumes(:volume_one).to_param
    assert_response :success
  end

  test "should update volume" do
    put :update, :id => volumes(:volume_one).to_param, :volume => { }
    assert_redirected_to volume_path(assigns(:volume))
  end

  test "should destroy volume" do
    assert_difference('Volume.count', -1) do
      delete :destroy, :id => volumes(:volume_one).to_param
    end

    assert_redirected_to volumes_path
  end
end
