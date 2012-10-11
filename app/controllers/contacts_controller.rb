class ContactsController < ApplicationController
  before_filter :authenticate_user!

  def new
    @contact = Contact.new

    respond_to do |format|
      format.html { render :action => :new, :layout => false }
    end
  end

  def create
    @contact = current_user.contacts.new(params[:contact])

    respond_to do |format|
      if @contact.save
        format.js {
          render :json => { success: true }
        }
      end
    end
  end
end
