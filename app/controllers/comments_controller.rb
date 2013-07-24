class CommentsController < ApplicationController
  #KJS. added for nested comments
  #new action is called when add a comment to a comment
  
  def new 
    #debugger
    if logged_in?
      @parent_id = params.delete(:parent_id)
      #@parent_id = params[:parent_id]
      @commentable = find_commentable
      puts "************ comments_controller: new .... parent_id : "  + @parent_id.to_s
      @comment = Comment.new( :parent_id => @parent_id, 
                              :commentable_id => @commentable.id,
                              :commentable_type => @commentable.class.to_s)

      @parent_comment = Comment.find(@parent_id)

      @comment_user = User.find(:first, :conditions => {:id => @parent_comment.user_id})

      comment_community_ids = []
      comment_annotations = CommentAnnotation.find(:all, :conditions => {:comment_id => @parent_id} )
      for annotation in comment_annotations
        comment_community_ids.push(annotation.community_id)
      end
      @commnent_communities = Community.find(:all, :conditions => ["id IN (?)", comment_community_ids])
    end
  end

  def create
    #debugger
    puts "******************  comments_controller: create"
    if logged_in?
      @commentable = find_commentable
      @comment = @commentable.comments.build(params[:comment])
      
      #from check-boxes
      selected_ids = [] 
      if params[:community_ids]
        selected_ids = params[:community_ids].collect {|id| id.to_i} 
        #puts "************** selected_id: " + selected_id.to_s
      end
      @parent_id = @comment.parent_id

      story_annotations = []
      
      if selected_ids.empty?
        debugger
        unless @comment.nil?
          story_annotations = CommentAnnotation.find(:all, :conditions => {:comment_id => @parent_id})
          debugger
        else
          story_annotations = Annotation.find(:all, :conditions => {:story_id => @commentable.id} )

        end
      end
      unless story_annotations.nil?
        for annotation in story_annotations
            #selected_ids.push(annotation.community_id)
            selected_ids.push(annotation.community_id)
        end
      end

      if @comment.save
        unless selected_ids.nil? || selected_ids.empty?
          selected_ids.each do |sel_id|
            #CommentAnnotation.new (:comment_id => @comment.id, :community_id => sel_id).save! ==> not working
            @comment_association = CommentAnnotation.new
            @comment_association.comment_id =  @comment.id
            @comment_association.community_id = sel_id
            @comment_association.save
          end
        end
        #@comment.update_attributes(:user_id  => current_user.id, :story_id => @commentable.id) ==> not working
        @comment.user_id = current_user.id
        @comment.story_id = @commentable.id
        @comment.save

      #debugger

      # increment story popularity
        story = Story.find(params[:story_id])
        story.increase_popularity(Story::ScoreComment)
        story.save

        flash[:notice] = "Successfully created comment."
        redirect_to @commentable
      # create activity
        # activity = ActivityItem.create(
        #   :story_id   => story.id,
        #   :user_id    => current_user.id,
        #   :topic_id   => story.topic_id,
        #   :comment_id => comment.id,
        #   :kind       => ActivityItem::CommentType)
      else
        flash[:error] = "Error adding comment."
      end
    else
      # todo: send back error response
    end

    #render :json => comment.to_json(:methods => :user)
  end

  def destroy
    if logged_in?
      @comment = Comment.find(params[:id])
      @comment.communities.delete_all #CommentAnnotation
      @comment.destroy
      if @comment.user == current_user
        @comment.story.decrease_popularity(Story::ScoreComment)
        @comment.story.save
        #comment.activity_item.delete
        
      end
      #render :json => ""
      redirect_back_or(root_url)
    end
  end

  private
  def find_commentable
    params.each do |name, value|
      if name =~ /(.+)_id$/
        return $1.classify.constantize.find(value)
      end
    end
    nil
  end
end