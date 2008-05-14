require_dependency 'application_helper'


ActionView::Base.class_eval do

  def labeled_form_for( name, *args, &block )
    raise ArgumentError, "Missing block" unless block_given?
    options = (args.last.is_a?(Hash) ? args.pop : {}).merge(:builder=>LabeledFormBuilder)
    class_name = options.has_key?(:class) ? options.delete(:class) : 'form-container'
    id = (options.has_key?(:html) and options[:html].has_key?(:id)) ? "#{options[:html][:id]}-container" : 'form-container'
    concat( %Q|<dl id="#{id}" class="#{class_name}">|, block.binding )
    form_for( name, *(args << options), &block )
    concat( '</dl>', block.binding )
  end

  def remote_labeled_form_for( name, *args, &block )
    raise ArgumentError, "Missing block" unless block_given?
    options = (args.last.is_a?(Hash) ? args.pop : {}).merge(:builder=>LabeledFormBuilder)
    class_name = options.has_key?(:class) ? options.delete(:class) : 'form-container'
    id = (options.has_key?(:html) and options[:html].has_key?(:id)) ? "#{options[:html][:id]}-container" : 'form-container'
    concat( %Q|<dl id="#{id}" class="#{class_name}">|, block.binding )
    remote_form_for( name, *(args<< options), &block )
    concat( '</dl>', block.binding )
  end
  alias :labeled_form_remote_for :remote_labeled_form_for

  def form_button_group(options={}, &block)
    raise ArgumentError, "Missing block" unless block_given?
    class_name = options.has_key?(:class) ? options.delete(:class) : 'button-group'
    concat( %Q|<dd class="#{class_name}">|, block.binding )
    concat( capture( &block ), block.binding )
    concat( '</dd>', block.binding )
  end
  
  def column_group(column="left", options={}, &block)
    raise ArgumentError, "Missing block" unless block_given?
    class_name = options.has_key?(:class) ? options.delete(:class) : 'column-group'
    class_name += " #{column}"
    concat( %Q|<div class="#{class_name}">|, block.binding )
    concat( capture( &block ), block.binding )
    concat( '</div>', block.binding )
  end

end