# Filters added to this controller will be run for all controllers in the application.
# Likewise, all the methods added will be available for all controllers.
class ApplicationController < ActionController::Base

  include AuthenticatedSystem

  # "remember me" support
  before_filter :login_from_cookie

  # Don't log passwords or binary data!
  filter_parameter_logging "password"
  filter_parameter_logging "data"

protected

  @@compiled_templates = {}

  def render_theme_template( template_name, ctx={} )
    ctx = Liquid::Context.new(ctx)
    content_tmpl = compile_template( template_name )
    layout_tmpl = compile_template( 'layout' )
    ctx['content_for_layout'] = content_tmpl.render(ctx)
    render :text=>layout_tmpl.render(ctx)
  end

  def compile_template( template_name )
    template_name += '.liquid' unless template_name.ends_with? '.liquid'
    # Caches the compiled template
    if @@compiled_templates[template_name].nil?
      tmpl_path = Theme.current.template_path( template_name )
      @@compiled_templates[template_name] = Liquid::Template.parse( IO.read(tmpl_path) )
    end
    @@compiled_templates[template_name]
  end

end