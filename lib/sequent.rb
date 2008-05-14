module Sequent
  # Base stuff here?
end

require 'sequent/version'
require 'sequent/publisher'
require 'sequent/crontab'
require 'sequent/liquid_context'
require 'sequent/liquid_filesystem'

# Install all the Liquid tags
Dir[File.join(File.dirname(__FILE__), 'sequent', 'tags', '*.rb')].each do |path|
  require "sequent/tags/#{File.basename(path)}"
end

# Install all the Liquid drops
Dir[File.join(File.dirname(__FILE__), 'sequent', 'drops', '*.rb')].each do |path|
  require "sequent/drops/#{File.basename(path)}"
end

# Install all the Liquid filters
Dir[File.join(File.dirname(__FILE__), 'sequent', 'filters', '*.rb')].each do |path|
  require "sequent/filters/#{File.basename(path)}"
end