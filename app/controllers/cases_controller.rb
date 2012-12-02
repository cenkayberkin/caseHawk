class CasesController < ApplicationController
  before_filter :authenticate_user!

  def new
    @case = Case.new
    @case.contacts.build

    respond_to do |format|
      format.html { render :action => :new, :layout => false }
    end
  end

  def edit
    @case = Case.find(params[:id])
    
    respond_to do |format|
      format.html { render :action => :edit, :layout => false }
    end
  end

  def create
    @case = current_user.cases.new(params[:case])

    respond_to do |format|
      if @case.save
        format.html do
          if request.xhr?
            render :partial => 'cases/recent'
          end
        end
      else
        format.html do
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
        format.html do
          if request.xhr?
            render :partial => 'cases/recent'
          end
        end
      else
        format.html do
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
end
