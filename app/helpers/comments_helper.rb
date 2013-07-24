module CommentsHelper
  def nested_comments(comments)
    comment_community_ids = []
    
  	unless comments.nil? || comments.empty?
	    comments.map do |comment, sub_comments|
        comment_annotations = CommentAnnotation.find(:all, :conditions => {:comment_id => comment.id} )
        for annotation in comment_annotations
          comment_community_ids.push(annotation.community_id)
        end
        @commnent_communities = Community.find(:all, :conditions => ["id IN (?)", comment_community_ids]) 
        
        content_tag(:div, :class => "nested_comments") do
          render(comment) + nested_comments(sub_comments)
          #KJS: move the code below to _comment.html.erb
          # concat(render(comment) )
          # concat(content_tag(:div, "Shared communities:", :class => "", :style => "font-color:'gray'; font-size:12px"))
          # @commnent_communities.each do |community| 
          #   concat(content_tag(:li, community.name, :style => "font-color:'gray'; font-size:12px"))
          # end
          # concat(nested_comments(sub_comments))
        end
        #end

        #render(comment) + content_tag(:div, nested_comments(sub_comments), :class => "nested_comments")
	    end.join.html_safe
	end
  end

  #
  #if type == 0, intersect story's communities with user's communities
  #if type == 1, intersect comment's communities with user's communities
  def intersected_communities(type, message, user_communities)
    annotations = []
  	if type == 0 #message_id is story_id
  		annotations = Annotation.find(:all, :conditions => ["story_id = ?", message.id.to_s]) 
  	elsif type == 1 #message_id is comment_id
  		annotations = CommentAnnotation.find(:all, :conditions => ["comment_id = ?", message.id]) 
  	end
  	sel_communities = []
    
  for annotation in annotations
      unless annotation.community_id.nil?
        sel_communities << Community.find(:first, :conditions => "id = " + annotation.community_id.to_s)
      end
    end
debugger
    results = []
    results = user_communities & sel_communities
    # if sel_communities.length >= user_communities.length # stories > sel_stories
    #   results = user_communities | sel_communities
    #   results = user_communities & results
    # else # sel_stories > stories
    #   results = user_communities | sel_communities
    #   results = results & sel_communities
    # end
    return results
  end
end