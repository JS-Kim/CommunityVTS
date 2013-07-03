class Ballot < ActiveRecord::Base
  #attr_accessible :author_id, :content_id, :member_id, :myballots_id, :myballots_type, :outcome, :over, :vote_type

  has_one :notification
  has_many :cvotes
  has_many :users, :through => :cvotes
  belongs_to :myballots, :polymorthic => true
  #vote_check is called every time someone submits a vote
  #This method will determine if a ballot is finished

  def self.vote_check(ballot)
  	#form a list of all the cvote approvals (e.g., [true, true, false, nil])
  	@cvotes = ballot.cvotes.map { |x| x.approval }.compact #all nil elements removed


  	#if ballot.vote_type == 'exception' # no exception for VTS. July. 3. 2013
  	if ballot.vote_type == 'new_community' #'new_tag' in CMail
  		finished = false
  		approved = nil
  		@community = Community.find(ballot.content_id) #through annotations
  		#if voting is done
  		if @cvotes.size == ballot.cvotes.size
  			#find the community (tag) then add everyone who voted 'yes' (all approval == 'true' votes)
  			finished = true
  			approved = true
  			ballot.cvotes.each do |v|
  				if v.approval
  					@cvote.users << v.user
  					@cvote.users << User.find(ballot.author_id)
  				end
  			end
  			#activate the community
  			@community.update_attributes('approved' => true)
  			ballot.update_attributes('over' => true, 'outcome' => 'success')
  		end #voting is done

  		if ballot.notification
  			ballot.notification.update_attributes(:message => "New Community (#{@community.name}): #{@cvotes.count}/#{ballot.cvotes.count} votes", :finished => finished, :approved => approved)
  		end
  	elsif ballot.vote_type == 'add_community_member' or ballot.vote_type == 'remove_community_member'
  		@community = Community.find(ballot.content_id)
  		if ballot.vote_type == 'add_community_member'
  			@message = "Add Member" 
  		else
  			@message = "Remove Member"
  		end
  		finished = false
  		approved = nil

  		if @cvotes.include?(false)
  			#ballot did not pass
  			ballot.update_attributes('ocver' => true, 'outcome' => 'failure')
  			finished = true
  			approved = false
  			@community.update_attributes(:voteable, true)
  		elsif @cvotes.size == ballot.cvotes.size and !@cvotes.include?(false)
  			finished = true
  			approved = true
  			#ballot passed
  			ballot.update_attributes('over' => true, 'outcome' => 'success')
  			#find the community and remove or add member depending on vote_type
  			if ballot.vote_type == 'add_community_member'
  				@community.users << User.find(ballot.member_id)
  			elsif ballot.vote_type == 'remove_community_member'
  				@community.users.delete(User.find(ballot.member_id))
  			end
  			@community.update_attributes(:voteable, true)
  		end
  		if ballot.notification
  			ballot.notification.update_attributes(:message => "#{@message} (#{@community.name}): #{@cvotes.count}/#{ballot.cvotes.count} votes", :finished => finished, :approved => approved)
  		end
  	else
  		#TODO: error handling since vote_type wasn't set
  	end
  end #self.vote_check
end
