class CommentsController < ApplicationController
  #KJS. added for nested comments
  #new action is called when add a comment to a comment
  
  def new 
    #debugger
    if logged_in?
      @parent_id = params.delete(:parent_id)
      @commentable = find_commentable
      @comment = Comment.new( :parent_id => @parent_id, 
                              :commentable_id => @commentable.id,
                              :commentable_type => @commentable.class.to_s)
    end
  end

  def create
    debugger
    puts "******************  comments_controller: create"
    if logged_in?
      @commentable = find_commentable
      # comment = Comment.create(
        #   :body     => params[:body].to_s,
        #   :user_id  => current_user.id,
        #   :story_id => params[:story_id].to_i)
        # comment.save
      @comment = @commentable.comments.build(params[:comment])
      
      if @comment.save
        @comment.update_attributes(:user_id  => current_user.id, :story_id => :parent_id)
      
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