require File.dirname(__FILE__) + '/test_helper'

#require File.join(File.dirname(__FILE__), 'abstract_unit')
#require File.join(File.dirname(__FILE__), 'fixtures/page')

#require 'breakpoint'

class ActsAsSluggableTest < Test::Unit::TestCase
  fixtures :pages

  def setup
    @allowable_characters = Regexp.new("^[A-Za-z0-9_-]+$")
  end

  def test_hooks_presence
    assert Page.before_validation_on_create.include?(:create_slug)
    assert Page.before_validation_on_update.include?(:create_slug)
  end

  def test_create
    # create, with title
    @page = Page.new(:title => "Creation")
    @page.save
    assert_equal "creation", @page.url_slug

    # create, with title and url_slug
    @page = Page.new(:title => "Test overrride", :parent_id => nil, :url_slug => "something-different")
    @page.save
    assert_equal "something-different", @page.url_slug

    # create, with nil title
    @page = Page.new(:title => nil)
    @page.save
    assert_not_nil @page.url_slug

    # create, with blank title
    @page = Page.new(:title => '')
    @page.save
    assert_not_nil @page.url_slug
  end

  def test_update
    @page = Page.new(:title => "Slug update")
    @page.save
    assert_equal "slug-update", @page.url_slug

    # update, with title
    @page.update_attribute(:title, "Updated title only")
    assert_equal "slug-update", @page.url_slug

    # update, with title and nil slug
    @page.update_attributes(:title => "Updated title and slug to nil", :url_slug => nil)
    assert_equal "updated-title-and-slug-to-nil", @page.url_slug
    
    # update, with empty slug
    @page.update_attributes(:title => "Updated title and slug to empty", :url_slug => '')
    assert_equal "updated-title-and-slug-to-empty", @page.url_slug
  end

  def test_uniqueness
    # create two pages with the same title and 
    # within the same scope - slugs should be unique
    title = "Unique title"

    @page1 = Page.new(:title => title, :parent_id => 1)
    @page1.save
    
    @page2 = Page.new(:title => title, :parent_id => 1)
    @page2.save
    
    assert_not_equal @page1.url_slug, @page2.url_slug
  end

  def test_scope
  # create two pages with the same title

  # but not in the same scope - slugs should be the same
  title = "Unique scoped title"

    @page1 = Page.new(:title => title, :parent_id => 1)
    @page1.save
    
    @page2 = Page.new(:title => title, :parent_id => 2)
    @page2.save

    assert_equal @page1.url_slug, @page2.url_slug
  end

  def test_characters
    check_for_allowable_characters "Title"
    check_for_allowable_characters "Title and some spaces"
    check_for_allowable_characters "Title-with-dashes"
    check_for_allowable_characters "Title-with'-$#)(*%symbols"
    check_for_allowable_characters "/urltitle/"
    check_for_allowable_characters "calculé en française"
  end

  private
    def check_for_allowable_characters(title)
      @page = Page.new(:title => title)
      @page.save
      assert_match @allowable_characters, @page.url_slug  
    end
end
