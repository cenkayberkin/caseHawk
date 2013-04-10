class ContactsController < ApplicationController
  before_filter :authenticate_user!

  def index
    @contacts = current_user.contacts

    respond_to do |format|
      format.json do
        render :json => @contacts.map { |c| { value: c.id, label: c.first_name + ' ' + c.last_name } }
      end
    end
  end

  def new
    @contact = current_user.contacts.create
    @contact.phone_numbers.build
    @contact.addresses.build
    @contact.email_addresses.build

    respond_to do |format|
      format.html { render :action => :edit, :layout => false }
    end
  end

  def edit
    @contact = Contact.find(params[:id])

    respond_to do |format|
      format.html { render :action => :edit, :layout => false }
    end
  end

  def create
    @contact = current_user.contacts.new(params[:contact])

    respond_to do |format|
      if @contact.save
        format.json do
          if request.xhr?
            render :json => {
              recent: render_to_string(:partial => 'recent', :formats => [ :html ]),
              html: render_to_string(:action => 'new', :layout => false, :formats => [ :html ])
            }
          end
        end
      else
        format.html do
          if request.xhr?
            render :json => @contact.errors.full_messages, :status => :unprocessable_entity
          end
        end
      end
    end
  end

  def update
    @contact = Contact.find(params[:id])

    respond_to do |format|
      if @contact.update_attributes(params[:contact])
        format.json do
          if request.xhr?
            render :json => {
              recent: render_to_string(:partial => 'recent', :formats => [ :html ]),
              summary: render_to_string(:partial => 'summary', :formats => [ :html ], :locals => { :contact => @contact })
            }
          end
        end
      else
        format.html do
          if request.xhr?
            render :json => @contact.errors.full_messages, :status => :unprocessable_entity
          end
        end
      end
    end
  end

  def destroy
    Contact.find(params[:id]).destroy

    respond_to do |format|
      format.html do
        if request.xhr?
          render :partial => 'contacts/recent'
        end
      end
    end
  end
end
