class LabeledFormBuilder < ActionView::Helpers::FormBuilder
    
  ((field_helpers - %w(check_box radio_button hidden_field)) + %w(datetime_select date_select)).each do |selector|
    src = <<-END_SRC
    def #{selector}(field, options = {})
        field_label, info, example = get_label(field, options)
        field_to_html( field_label, field, super, false, info, example )
    end
    END_SRC
    class_eval src, __FILE__, __LINE__
  end
  
  def select( field, choices, options = {}, html_options = {})
    field_label, info, example = get_label(field, options)
    field_to_html( field_label, field, super, false, info, example )
  end
  
  def check_box(field, options = {}, checked_value = "1", unchecked_value = "0")
    field_label, info, example = get_label(field, options)
    field_to_html( field_label, field, super, true, info, example )
  end
  
  def radio_button(field, tag_value, options = {})
    field_label, info, example = get_label(tag_value, options)
    field_to_html( field_label, field, super, true, info, example )
  end
  
  def button_group(options={}, &block)
    @template.form_button_group(options, &block)
  end
  
  def left_column(options={}, &block)
     @template.column_group(options, &block)
  end
   
  def right_column(options={}, &block)
     @template.column_group('right', options, &block)
  end
  
protected
  
  def field_to_html(label, field, field_html, is_checkbox=false, info=nil, example=nil )
    field_name = "#{@object_name}_#{field.to_s.underscore}"
    info_html = (info.nil?) ? '' : @template.content_tag( 'span', info, :class=>'info' )
    example_html = (example.nil?) ? '' : @template.content_tag('dd', example, :class=>'example' )
    unless is_checkbox
      @template.content_tag('dt', @template.content_tag( 'label', label, :for=>field_name ) + info_html ) + @template.content_tag('dd', field_html ) + example_html
    else
      @template.content_tag('dd', field_html + @template.content_tag('label', label, :for=>field_name) + info_html ) + example_html
    end
  end
  
  def get_label(field, options)
    info = options.delete :info
    example = options.delete :example
    label = options.has_key?(:label) ? options.delete(:label) : field.to_s.humanize.titleize
    label += ":"
    return [label, info, example]
  end
  
end