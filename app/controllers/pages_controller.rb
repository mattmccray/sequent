class PagesController < AdminController

  cache_sweeper :site_sweeper, :only => [ :update, :destroy, :create ]

  # GET /pages
  # GET /pages.xml
  def index
    @pages = Page.find(:all, :order=>'title')

    respond_to do |format|
      format.html # index.rhtml
      format.xml  { render :xml => @pages.to_xml }
    end
  end

  # GET /pages/1
  # GET /pages/1.xml
  def show
    @page = Page.find(params[:id])

    respond_to do |format|
      format.html # show.rhtml
      format.xml  { render :xml => @page.to_xml }
    end
  end

  # GET /pages/new
  def new
    @page = Page.new(:title=>'New Page')
  end

  # GET /pages/1;edit
  def edit
    @page = Page.find(params[:id])
  end

  # POST /pages
  # POST /pages.xml
  def create
    @page = Page.new(params[:page])

    respond_to do |format|
      if @page.save
        expire_action( page_url(nil) )
        expire_action( home_url() )

        # Add Attachments
        params[:attachments].each do |att|
          @page.attachments.create :uploadedfile=>att
        end if params.has_key?( :attachments )        

        flash[:notice] = 'Page was successfully created.'
        format.html { redirect_to pages_url }
        format.xml  { head :created, :location => pages_url }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @page.errors.to_xml }
      end
    end
  end

  # PUT /pages/1
  # PUT /pages/1.xml
  def update
    @page = Page.find(params[:id])

    respond_to do |format|
      if @page.update_attributes(params[:page])
        expire_action( page_url(:slug=>@page.slug) )
        expire_action( page_url(nil) )
        expire_action( home_url() )
        
        # Add/Remove attachments
        params[:attachments].each do |att|
          @page.attachments.create :uploadedfile=>att
        end if params.has_key?( :attachments )        
        params[:removed_attachments].each do |att_id|
          begin # Let's be safe about it...
            @page.attachments.find(att_id).destroy
          rescue
            STDERR.puts "#{att_id} isn't a valid ID for this page."
          end
        end if params.has_key?( :removed_attachments )
                
        flash[:notice] = 'Page was successfully updated.'
        format.html { redirect_to pages_url }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @page.errors.to_xml }
      end
    end
  end

  # DELETE /pages/1
  # DELETE /pages/1.xml
  def destroy
    @page = Page.find(params[:id])
    expire_action( page_url(:slug=>@page.slug) )
    expire_action( page_url(nil) )
    expire_action( home_url() )
    @page.destroy

    respond_to do |format|
      format.html { redirect_to pages_url }
      format.xml  { head :ok }
    end
  end
end
