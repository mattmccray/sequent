module SiteHelper

  def list_panel(items, options={})
    options.reverse_merge!({:label=>'Items', :prefix=>'items'})
    html = %{
      <dt><label>#{options[:label]}</label></dt>
      <dd>
        <div id="item-template" style="display:none;">
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


end