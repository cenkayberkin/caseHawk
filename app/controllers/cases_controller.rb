class CasesController < ApplicationController
  before_filter :authenticate_user!

  def new
    @case = current_user.cases.create
    @case.case_contacts.build

    if params[:contact_id].present?
      @case.case_contacts.contact.create(Contact.find(params[:contact_id]))
    end

    respond_to do |format|
      format.html { render :action => :edit, :layout => false }
    end
  end

  def edit
    @case = Case.find(params[:id])
    @case.case_contacts.build if @case.case_contacts.blank?

    if params[:contact_id].present?
      @case.case_contacts.contact.create(Contact.find(params[:contact_id]))
    end

    respond_to do |format|
      format.html { render :action => :edit, :layout => false }
    end
  end

  def create
    @case = current_user.cases.new(params[:case])

    respond_to do |format|
      if @case.save
        format.json do
          if request.xhr?
            render :json => {
              recent: render_to_string(:partial => 'recent', :formats => [ :html ]),
              html: render_to_string(:action => 'edit', :layout => false, :formats => [ :html ])
            }
          end
        end
      else
        format.json do
          if request.xhr?
            render :json => @case.errors.full_messages, :status => :unprocessable_entity
          end
        end
      end
    end
  end

  def update
    @case = Case.find(params[:id])

    respond_to do |format|
      if @case.update_attributes(params[:case])
        format.json do
          if request.xhr?
            render :json => {
              recent: render_to_string(:partial => 'recent', :formats => [ :html ]),
              summary: render_to_string(:partial => 'summary', :formats => [ :html ], :locals => { :kase => @case })
            }
          end
        end
      else
        format.json do
          if request.xhr?
            render :json => @case.errors.full_messages, :status => :unprocessable_entity
          end
        end
      end
    end
  end

  def destroy
    Case.find(params[:id]).destroy

    respond_to do |format|
      format.html do
        if request.xhr?
          render :partial => 'cases/recent'
        end
      end
    end
  end

  def notes
    @case = Case.find(params[:id])
    @case.notes.create(:title => "New note")

    render :layout => false
  end

  def contacts
    @case = Case.find(params[:id])
    @case.case_contacts.create(:contact_id => current_user.contacts.last.id)

    render :layout => false
  end
end
