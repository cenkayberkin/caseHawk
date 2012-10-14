class ContactsController < ApplicationController
  before_filter :authenticate_user!

  def new
    @contact = Contact.new
    @contact.phone_numbers.build
    @contact.addresses.build
    @contact.email_addresses.build

    respond_to do |format|
      format.html { render :action => :new, :layout => false }
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
        format.html do
          if request.xhr?
            render :partial => 'contacts/recent'
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
        format.html do
          if request.xhr?
            render :partial => 'contacts/recent'
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
