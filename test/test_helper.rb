ENV["RAILS_ENV"] = "test"
require File.expand_path(File.dirname(__FILE__) + "/../config/environment")
require 'test_help'

class Test::Unit::TestCase
  # Transactional fixtures accelerate your tests by wrapping each test method
  # in a transaction that's rolled back on completion.  This ensures that the
  # test database remains unchanged so your fixtures don't have to be reloaded
  # between every test method.  Fewer database queries means faster tests.
  #
  # Read Mike Clark's excellent walkthrough at
  #   http://clarkware.com/cgi/blosxom/2005/10/24#Rails10FastTesting
  #
  # Every Active Record database supports transactions except MyISAM tables
  # in MySQL.  Turn off transactional fixtures in this case; however, if you
  # don't care one way or the other, switching from MyISAM to InnoDB tables
  # is recommended.
  self.use_transactional_fixtures = true

  # Instantiated fixtures are slow, but give you @david where otherwise you
  # would need people(:david).  If you don't want to migrate your existing
  # test cases which use the @david style and don't mind the speed hit (each
  # instantiated fixtures translates to a database query per test method),
  # then set this back to true.
  self.use_instantiated_fixtures  = false

  # Add more helper methods to be used by all tests here...
end



require 'color'
module Test::Unit
  
  class Error
    # the 'E' that is displayed as the tests are run
    def single_character_display
      "E".red.bold
    end
    
    # the long message that is displayed after test is run
    def long_display
      backtrace = filter_backtrace(@exception.backtrace).join("\n    ")
      [
        "Error".red.bold, 
        ":\n", 
        "#@test_name:".white, 
        "\n", "#{message}".red, 
        "\n    #{backtrace}".gsub(/:(\d+):/,":#{'\1'.red}:")
      ].join('')
    end
  end
  
  
  class Failure
    # the 'E' that is displayed as the tests are run
    def single_character_display
      "F".yellow.bold
    end
    
    # the long message that is displayed after test is run
    def long_display
      location_display = if(location.size == 1)
        location[0].sub(/\A(.+:\d+).*/, ' [\\1]')
      else
        "\n    [#{location.join("\n     ")}]"
      end
      [
        "Failure".yellow.bold, 
        ":\n","#@test_name".white, 
        "#{location_display}".gsub(/:(\d+)/, ":#{'\1'.yellow}"), 
        ":\n", "#@message".yellow
      ].join('')
    end
  end
  
  # it is necessary to do a class_eval for the TestRunner class
  # through the AutoRunner class, since the require in the AutoRunner
  # class will overwrite what we do here otherwise.
  # 
  # We must do the same thing inside of the TestRunner class
  # class_eval for the TestResult class.  We Modify the
  # TestRunnerMediator class after the require is called,
  # which will then modify the TestResult class.
  #
  # test_finished is the function that will output the
  # '.' period during the test runs
  #
  # the to_s for TestResult class returns the string
  # for the final tallied results
  class AutoRunner
    RUNNERS[:console] = proc do |r|
      require 'test/unit/ui/console/testrunner'
      Test::Unit::UI::Console::TestRunner.class_eval %q{
        def test_finished(name)
          output_single('.'.green, 1) unless (@already_outputted)
          nl(3)
          @already_outputted = false
        end
        
        def create_mediator(suite)
          require 'test/unit/ui/testrunnermediator'
          Test::Unit::UI::TestRunnerMediator.class_eval %q{
            def create_result
              Test::Unit::TestResult.class_eval %q{
                def to_s
                  rc = [
                      "#{run_count}".white.bold, 
                      "tests".white
                    ].join(' ')
                  ac = [
                      "#{assertion_count}".white.bold, 
                      "assertions".white
                    ].join(' ')
                  fc = [
                      "#{failure_count}".yellow.bold, 
                      "failures".yellow
                    ].join(' ')
                  ec = [
                      "#{error_count}".red.bold, 
                      "errors".red
                    ].join(' ')
                  [rc, ac, fc, ec].join(', ')
                end
              }
              TestResult.new
            end
          }
          return Test::Unit::UI::TestRunnerMediator.new(suite)
        end
      }
      Test::Unit::UI::Console::TestRunner
    end
  end
  
end

