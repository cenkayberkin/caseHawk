# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def app_name
    'CaseHawk'
  end

  def flash_notices
    raw([:notice, :error, :alert].collect {|type| content_tag('div', flash[type], :id => type) if flash[type] }.join)
  end

  # Render a submit button and cancel link
  def submit_or_cancel(cancel_url = session[:return_to] ? session[:return_to] : url_for(:action => 'index'), label = 'Save Changes', submit_html_options = {})
    raw(content_tag(:div, submit_tag(label, submit_html_options) + ' or ' +
      link_to('Cancel', cancel_url), :id => 'submit_or_cancel', :class => 'submit'))
  end

  def link_to_add_fields name, f, association
    new_object = f.object.send(association).klass.new
    id         = new_object.object_id

    fields = f.fields_for(association, new_object, child_index: id) do |builder|
      render(association.to_s.singularize + '_fields', f: builder)
    end

    link_to(name, '#', class: 'add_fields', data: { id: id, fields: fields.gsub("\n", "") })
  end
end
