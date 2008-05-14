require File.dirname(__FILE__) + '/../test_helper'
require 'strips_controller'

# Re-raise errors caught by the controller.
class StripsController; def rescue_action(e) raise e end; end

class StripsControllerTest < Test::Unit::TestCase
  fixtures :assets

  def setup
    @controller = StripsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_should_get_index
    get :index
    assert_response :success
    assert assigns(:strips)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end
  
  def test_should_create_strip
    old_count = Strip.count
    post :create, :strip => { }
    assert_equal old_count+1, Strip.count
    
    assert_redirected_to strip_path(assigns(:strip))
  end

  def test_should_show_strip
    get :show, :id => 3
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => 3
    assert_response :success
  end
  
  def test_should_update_strip
    put :update, :id => 3, :strip => { }
    assert_redirected_to strip_path(assigns(:strip))
  end
  
  def test_should_destroy_strip
    old_count = Strip.count
    delete :destroy, :id => 3
    assert_equal old_count-1, Strip.count
    
    assert_redirected_to strips_path
  end
end
