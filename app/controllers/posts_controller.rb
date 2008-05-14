class PostsController < AdminController

  cache_sweeper :site_sweeper, :only => [ :update, :destroy, :create ]

  # GET /posts
  # GET /posts.xml
  def index
    @posts = Post.find(:all, :order=>'created_on DESC')

    respond_to do |format|
      format.html # index.rhtml
      format.xml  { render :xml => @posts.to_xml }
    end
  end

  # GET /posts/1
  # GET /posts/1.xml
  def show
    @post = Post.find(params[:id])

    respond_to do |format|
      format.html # show.rhtml
      format.xml  { render :xml => @post.to_xml }
    end
  end

  # GET /posts/new
  def new
    @post = Post.new(:title=>'New Post')
  end

  # GET /posts/1;edit
  def edit
    @post = Post.find(params[:id])
  end

  # POST /posts
  # POST /posts.xml
  def create
    @post = Post.new(params[:post])

    respond_to do |format|
      if @post.save
        expire_action( news_url(nil) )
        expire_action( home_url() )
        
        params[:attachments].each do |att|
          @post.attachments.create :uploadedfile=>att
        end if params.has_key?( :attachments )
        
        flash[:notice] = 'Post was successfully created.'
        format.html { redirect_to posts_url }
        format.xml  { head :created, :location => posts_url }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @post.errors.to_xml }
      end
    end
  end

  # PUT /posts/1
  # PUT /posts/1.xml
  def update
    @post = Post.find(params[:id])

    respond_to do |format|
      if @post.update_attributes(params[:post])
        expire_action( news_url(:slug=>@post.slug) )
        expire_action( news_url(nil) )
        expire_action( home_url() )

        # Add/Remove attachments
        params[:attachments].each do |att|
          @post.attachments.create :uploadedfile=>att
        end if params.has_key?( :attachments )
        params[:removed_attachments].each do |att_id|
          begin # Let's be safe about it...
            @post.attachments.find(att_id).destroy
          rescue
            STDERR.puts "#{att_id} isn't a valid ID for this post."
          end
        end if params.has_key?( :removed_attachments )

        flash[:notice] = 'Post was successfully updated.'
        format.html { redirect_to posts_url }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @post.errors.to_xml }
      end
    end
  end

  # DELETE /posts/1
  # DELETE /posts/1.xml
  def destroy
    @post = Post.find(params[:id])
    expire_action( news_url(:slug=>@post.slug) )
    expire_action( news_url(nil) )
    expire_action( home_url() )
    @post.destroy

    respond_to do |format|
      format.html { redirect_to posts_url }
      format.xml  { head :ok }
    end
  end
end
