module CommentsHelper
  def nested_comments(comments)
  	unless comments.nil? || comments.empty?
	    comments.map do |comment, sub_comments|
	      render(comment) + content_tag(:div, nested_comments(sub_comments), :class => "nested_comments")
	    end.join.html_safe
	end
  end

  #
  #if type == 0, intersect story's communities with user's communities
  #if type == 1, intersect comment's communities with user's communities
  def intersected_communities(type, message, user_communities)
  	if type == 0 #message_id is story_id
  		annotations = Annotation.find(:all, :conditions => ["story_id = ?", message.id.to_s]) 
  	elsif type == 1 #message_id is comment_id
  		annotations = CommentAnnotation.find(:all, :conditions => ["comment_id = ?", message.id.to_s]) 
  	end
  	sel_communities = []
    for annotation in annotations
      sel_communities << Community.find(:first, :conditions => "id = " + annotation.community_id.to_s)
    end
    
    results = []
    if sel_communities.length >= user_communities.length # stories > sel_stories
      results = user_communities | sel_communities
      results = user_communities & results
    else # sel_stories > stories
      results = user_communities | sel_communities
      results = results & sel_communities
    end
    return results
  end
end