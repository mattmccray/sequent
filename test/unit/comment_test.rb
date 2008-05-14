require File.dirname(__FILE__) + '/../test_helper'

class CommentTest < Test::Unit::TestCase
  fixtures :comments

  def test_crud
    # create a simple comment
    cmt = Comment.new( :body=>'Hello, *sir*' )

    # save it
    assert cmt.save

    # read it back
    cmtr = Comment.find(cmt.id)

    # compare the bodies
    assert_equal cmt.body, cmtr.body

    # simple render_column test
    assert_equal "<p>Hello, <strong>sir</strong></p>", cmtr.rendered_body
    
    # the agent gets killed
    assert cmt.destroy
  end
  
  def test_read
    assert_not_nil Comment.find(1)
  end
  

end
