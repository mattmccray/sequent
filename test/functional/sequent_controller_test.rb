require File.dirname(__FILE__) + '/../test_helper'
require 'sequent_controller'

# Re-raise errors caught by the controller.
class SequentController; def rescue_action(e) raise e end; end

class SequentControllerTest < Test::Unit::TestCase
  def setup
    @controller = SequentController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  # Replace this with your real tests.
  def test_truth
    assert true
  end
end
