module ModelControllerMethods

  def self.included(base)
    base.send :before_filter, :build_object, :only => [ :new, :create ]
    base.send :before_filter, :load_object, :only => [ :show, :edit, :update, :destroy ]
  end
  
  def index
    self.instance_variable_set('@' + self.controller_name,
      scoper.find(:all, :order => order_by))

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @obj }
      format.js { render :json => @obj }
    end
  end
  
  def create
    if @obj.save
      flash[:notice] = "The #{cname.humanize.downcase} has been created."
      redirect_back_or_default redirect_url
    else
      logger.info(@obj.errors.inspect)
      render :action => 'new'
    end
  end

  def update
    if @obj.update_attributes(params[cname])
      flash[:notice] = "The #{cname.humanize.downcase} has been updated."
      redirect_back_or_default redirect_url
    else
      render :action => 'edit'
    end
  end
  
  def destroy
    @result = @obj.destroy
    respond_to do |wants|
      wants.html do
        if @result
          flash[:notice] = "The #{cname.humanize.downcase} has been deleted."
          redirect_back_or_default redirect_url
        else
          render :action => 'show'
        end
      end
      
      wants.js do
        # If we have made it this far, the object is DABLETED! Send it back for removal from the page
        render :json => @obj
      end
    end
  end
  
  protected
  
    def cname
      @cname ||= controller_name.singularize
    end
    
    def set_object
      @obj ||= self.instance_variable_get('@' + cname)
    end
    
    def load_object
      @obj = self.instance_variable_set('@' + cname,  scoper.find(params[:id]))
    end
    
    def build_object
      @obj = self.instance_variable_set('@' + cname, scoper.new(params[cname]))
    end
    
    def scoper
      Object.const_get(cname.classify)
    end
    
    def redirect_url
      { :action => 'index' }
    end
    
end
