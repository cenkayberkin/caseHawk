# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def flash_notices
    [:notice, :error].collect {|type| content_tag('div', flash[type], :class => type) if flash[type] }
  end
  
  # Render a submit button and cancel link
  def submit_or_cancel(cancel_url = session[:return_to] ? session[:return_to] : url_for(:action => 'index'), label = 'Save Changes')
    content_tag(:div, submit_tag(label) + ' or ' +
      link_to('Cancel', cancel_url), :id => 'submit_or_cancel', :class => 'submit')
  end
end
