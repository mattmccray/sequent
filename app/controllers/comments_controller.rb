class CommentsController < AdminController

  skip_before_filter :login_required, :only=>:create
  cache_sweeper :site_sweeper, :only => [ :update, :destroy, :create ]

  # GET /comments
  # GET /comments.xml
  def index
    @comments = Comment.find(:all, :order=>'created_on DESC')
    @comments_grouped = @comments.group_by &:is_spam
    respond_to do |format|
      format.html # index.rhtml
      format.xml  { render :xml => @comments.to_xml }
    end
  end

  # GET /comments;unmoderated
  def unmoderated
    @comments = Comment.find(:all, :conditions=>['is_spam = ?', true])
    #@comments_grouped = @comments.group_by &:commentable
    render :index
  end


  # GET /comments/1
  # GET /comments/1.xml
  def show
    @comment = Comment.find(params[:id])
    respond_to do |format|
      format.html # show.rhtml
      format.xml  { render :xml => @comment.to_xml }
    end
  end

  # GET /comments/new
  def new
    @comment = Comment.new
  end

  # GET /comments/1;edit
  def edit
    @comment = Comment.find(params[:id])
  end

  # POST /comments
  # POST /comments.xml
  def create
    @comment = Comment.new(params[:comment])
    respond_to do |format|
      if @comment.save
        flash[:notice] = 'Comment was successfully created.'
        format.html { redirect_to :back }
        format.xml  { head :created, :location => comment_url(@comment) }
      else
        format.html { redirect_to :back }
        format.xml  { render :xml => @comment.errors.to_xml }
      end
    end
  rescue ActionController::RedirectBackError
    redirect_to "/"
  end

  # PUT /comments/1
  # PUT /comments/1.xml
  def update
    @comment = Comment.find(params[:id])
    # FIXME: If updating comment.is_spam = false, should I notify Akismet 'not spam'?

    respond_to do |format|
      if @comment.update_attributes(params[:comment])
        flash[:notice] = 'Comment was successfully updated.'
        format.html { redirect_to comments_url }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @comment.errors.to_xml }
      end
    end
  end

  # DELETE /comments/1
  # DELETE /comments/1.xml
  def destroy
    @comment = Comment.find(params[:id])
    # FIXME: If comment.is_spam -- should anything be done?
    @comment.destroy

    respond_to do |format|
      format.html { redirect_to comments_url }
      format.xml  { head :ok }
    end
  end
end
