class StripsController < AdminController

  cache_sweeper :site_sweeper, :only => [ :update, :destroy, :create ]

  # GET /strips
  # GET /strips.xml
  def index
    @strips, @strip_dates = strips_and_date_groups
    respond_to do |format|
      format.html # index.rhtml
      format.xml  { render :xml => @strips.to_xml }
    end
  end

  # GET /strips/1
  # GET /strips/1.xml
  def show
    @strip = Strip.find(params[:id])

    respond_to do |format|
      format.html # show.rhtml
      format.xml  { render :xml => @strip.to_xml }
    end
  end

  # GET /strips/new
  def new
    @strip = Strip.new(:published_on=>Date.today.to_time, :title=>'New Strip')
    @strips, @strip_dates = strips_and_date_groups
  end

  # GET /strips/1;edit
  def edit
    @strip = Strip.find(params[:id])
    @strips, @strip_dates = strips_and_date_groups
  end

  # POST /strips
  # POST /strips.xml
  def create
    @strip = Strip.new(params[:strip])
    
    # make sure it's set to 00:00h
    @strip.published_on = @strip.published_on.to_date.to_time

    respond_to do |format|
      if @strip.save
        flash[:notice] = 'Strip was successfully created.'
        # Reorder strips based on publish_on date...
        Strip.find(:all, :order=>'published_on').each_with_index do |strip, i|
          strip.update_attribute('position', i+1) 
        end
        @strip.reload
        
        format.html { redirect_to strips_url }
        format.xml  { head :created, :location => strips_url }
      else
        @strips, @strip_dates = strips_and_date_groups
        STDERR.puts "EXCEPTION #{$!}: #{@strip.errors.to_yaml}"
        format.html { render :action => "new" }
        format.xml  { render :xml => @strip.errors.to_xml }
      end
    end
  end

  # PUT /strips/1
  # PUT /strips/1.xml
  def update
    @strip = Strip.find(params[:id])

    respond_to do |format|
      if @strip.update_attributes(params[:strip])
        # Round to 00:00h
        @strip.update_attribute('published_on', (@strip.published_on.to_date.to_time))
        
        # Reorder strips based on publish_on date...
        Strip.find(:all, :order=>'published_on').each_with_index do |strip, i|
          strip.update_attribute('position', i+1) 
        end
        
        @strip.reload
        
        # Move them from/to .pending folder, depending
        @strip.publish_files
        
        flash[:notice] = 'Strip was successfully updated.'
        format.html { redirect_to strips_url }
        format.xml  { head :ok }
      else
        @strips, @strip_dates = strips_and_date_groups
        format.html { render :action => "edit" }
        format.xml  { render :xml => @strip.errors.to_xml }
      end
    end
  end

  # DELETE /strips/1
  # DELETE /strips/1.xml
  def destroy
    @strip = Strip.find(params[:id])
    @strip.destroy
    respond_to do |format|
      format.html { redirect_to strips_url }
      format.xml  { head :ok }
    end
  end
  
private

  def strips_and_date_groups
    strips = Strip.find(:all, :order=>'published_on DESC')
    strip_dates = {}
    # Need a list of Date -- not Times...
    strips.each { |s| strip_dates[s.published_on.to_date] = s }
    [strips, strip_dates]
  end
  
  
end
