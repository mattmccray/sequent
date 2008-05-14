require 'calendar_helper'

ActionView::Base.send :include, CalendarHelper
ApplicationHelper.send :include, CalendarHelper
