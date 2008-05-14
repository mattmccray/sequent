module CommentsHelper

  def approve_button( label="Approve", path=nil, options={} )
    conf_msg = options.reverse_merge!( :confirm=>'Are you you want to approve this comment?', :type=>'submit', :title=>label, :class=>'approve-icon').delete :confirm
    %{<form class="inline" oldonsubmit="return confirm('#{conf_msg}');" action="#{path}" method="POST"><input type="hidden" name="_method" value="put"/><input type="hidden" name="comment[is_spam]" value="false">#{button_html label, options}</form>}
  end


end
