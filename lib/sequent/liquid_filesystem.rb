# Liquid::Template.file_system = Sequent::FileSystem.new

module Sequent
  class LiquidFileSystem
    def read_template_file(template)
      #template += '.liquid' unless template.ends_with? '.liquid'
      # Force a 'partial' like include...
      template = "_#{template}#{'.liquid' unless template.ends_with?('.liquid')}"
      IO.read( Theme.current.template_path( template ) )
    end
  end
end

Liquid::Template.file_system = Sequent::LiquidFileSystem.new
