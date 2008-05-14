module AdminHelper

  def get_link(comment, redirect_spam=true)
    if comment.is_spam and redirect_spam
      url_for :controller=>'comments', :action=>'index'
    else
      case comment.commentable.class.to_s.downcase
      when 'post'
        news_url :slug=>comment.commentable.slug
      when 'page'
        page_url :slug=>comment.commentable.slug
      when 'strip'
        comic_url :id=>comment.commentable.position
      else
        '#'
      end
    end
  end

  def label_for( builder, field, label=nil )
    label ||= field.to_s.capitalize
    %{<label for="#{builder.object_name}_#{field}">#{label}</label>}
  end

  # Buttons!

  def submit_button( label="Submit", options={} )
    button_html label, options.merge(:type=>'submit')
  end
  
  def delete_button( label="Delete", path=nil, options={} )
    conf_msg = options.reverse_merge!( :confirm=>'Are you sure?', :type=>'submit', :title=>label).delete :confirm
    %{<form class="inline" onsubmit="return confirm('#{conf_msg}');" action="#{path}" method="POST"><input type="hidden" name="_method" value="delete"/>#{button_html label, options}</form>}
  end  
  
  def link_button( label, path, options={} )
    button_html label, options.merge(:onclick=>"location.href='#{path}'", :type=>'button')
  end
  
  def button_html( label, attributes={} )
    attrs = []
    attributes.keys.map {|a| attrs << %{#{a.to_s}="#{attributes[a]}"} }
    %{<button #{attrs.join(' ')}><div>#{label}</div></button>}
  end
  
  # Fields!
  
  def attachment_panel(attachments, options={})
    options.reverse_merge!({:label=>'Attachments'})
    html = %{
      <dt><label>#{options[:label]}</label></dt>
      <dd>
        <div id="attachment-template" style="display:none;">
          <div class="attachment-row last-row">
            <button class="delete-icon" type="button" onmouseover="AttachmentController.hover(this,true)" onmouseout="AttachmentController.hover(this,false)" onclick="AttachmentController.remove(this);return false;" title="Remove this attachment"><div>Remove this attachment</div></button>
            <input type="file" name="attachments[]" onchange="AttachmentController.changed(this);"/>
            <span class="filename">&nbsp;</span>
          </div>
        </div>
        <div id="existing-attachments">
          #{ attachments.map do |att|
          %{<div id="#{att.id}" class="attachment-row">
              <button class="delete-icon" type="button" onmouseover="AttachmentController.hover(this,true)" onmouseout="AttachmentController.hover(this,false)" onclick="AttachmentController.mark_as_removed(this);return false;" title="Remove this attachment"><div>Remove this attachment</div></button>
              <span>#{att.title}</span>
            </div>}
          end.join(' ') }
        </div>
        <div id="attachment-list">
        </div>
      </dd>
      <script>
        $(document).ready(function(){
          AttachmentController.init();
        });
      </script>
    }
  end
  
  def date_picker_field(object, method, label=nil)
    obj = instance_eval("@#{object}")
    value = obj.send(method)
    label = label || method.to_s.titleize
    display_value = value.respond_to?(:strftime) ? value.strftime('%d %b %Y') : value.to_s
    display_value = '[ choose date ]' if display_value.blank?
    out = %{<dt><label for="#{object}_#{method}">#{label}:</label></dt><dd>}
    out << %{<input type="hidden" id="#{object}_#{method}" name="#{object}[#{method}]" value="#{value.to_s(:db) || value}" />}
    out << content_tag('a', display_value, :href => '#',
        :id => "_#{object}_#{method}_link", :class => 'datepicker_link',
        :onclick => "DatePicker.toggleDatePicker('#{object}_#{method}'); return false;")
    out << %{<div class='date_picker style='display: none' id="_#{object}_#{method}_calendar"></div>}
    out << "</dd>"
    if obj.respond_to?(:errors) and obj.errors.on(method) then
      ActionView::Base.field_error_proc.call(out, nil) # What should I pass ?
    else
      out
    end
  end


end
