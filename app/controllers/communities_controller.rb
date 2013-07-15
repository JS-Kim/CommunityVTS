class CommunitiesController < ApplicationController

  def update_selections
    #check_box handler
    if params[:unchecked_ids]
      unselected_ids = params[:unchecked_ids].collect {|id| id.to_i} 
      if unselected_ids
        unselected_ids.each do |id|
          #@community = current_user.communities.find_by_id(id) #KJS: doens't work properly.
          @unselectedmemberships = Membership.find(:all, :conditions => ["community_id = " + id.to_s + " AND " + "user_id = " + current_user.id.to_s])
          @unselectedmemberships.each do |m|                  
            Membership.unselect_communities(m)
          end 
        end
        flash[:notice] = "Your selection was successfull."
      end
    end
    if params[:community_ids]
      selected_ids = params[:community_ids].collect {|id| id.to_i} 
            
      if selected_ids
        selected_ids.each do |id|
          #@community = current_user.communities.find_by_id(id) #KJS: doens't work properly. find all communities.
          @selectedmemberships = Membership.find(:all, :conditions => ["community_id = " + id.to_s + " AND " + "user_id = " + current_user.id.to_s])
          @selectedmemberships.each do |m|                  
            Membership.select_communities(m)
          end       
          flash[:notice] = "Your selection was successfull."
        end
      end
    end
    redirect_to(:action => "index")
    return
  end
  # GET /communities
  # GET /communities.json
  def index
    if logged_in?
      @filter = params[:filter]

      if @filter.nil?
        @filter = "current"
      end

      if @filter == "current"
        @communities = current_user.communities.current_communities
      elsif @filter == "archived"
        @communities = current_user.communities.archived_communities
      else
        @communities = []
      end

      @myCommunities = current_user.communities.autocomplete(params[:term])
      @selected = []
      @myCommunities.each do |c|
       
      @membership = Membership.find(:first, :conditions => ["community_id = " + c.id.to_s + " AND " + "user_id = " + current_user.id.to_s])
      @selected << Membership.selected?(@membership)
        #@sel = Membership.selected?(@membership)
        #flash[:notice] = "selected:" + @sel.to_s
      end
     
      respond_to do |format|
        format.html # index.html.erb
        format.json {
          @communityNames = []
          @selected = []
          @myCommunities.each do |c|
            @communityNames << c.name
          end
          # render :json => { :communityNames => @communityNames, :selected => @selected }
          render :json => @communityNames
        }
      end
      
    else
      flash[:alert] = "You need to be logged in to list your communities."
      redirect_to login_url
    end  
  end
  
  # GET /communities/1
  # GET /communities/1.json
  def show
    if logged_in?
      @community = Community.find(params[:id])

      respond_to do |format|
        format.html # show.html.erb
        format.xml  { render :xml => @community }
        #format.json { render json: @community }
      end
    end
  end

  # GET /communities/new
  # GET /communities/new.json
  def new
    if logged_in?
      @community = Community.new

      respond_to do |format|
        format.html # new.html.erb
        format.xml  { render :xml => @community }
      end
    end
  end

  # GET /communities/1/edit
  def edit
    @community = Community.find(params[:id])
  end

  # POST /communities
  # POST /communities.json
  def create
    if logged_in?

      @community = Community.new(params[:community])
      @community.name.strip!

    #invalid_members and invalid_communities used for COPS error reporting
      @invalid_members = []
      @invalid_communities = []
    
    #'members' will hold all of the potential members for this community
      @members = [current_user]

    #if user entered some email addresses add them to @members
      if !params[:members].nil?
        @member_emails = params[:members].split(/[,;]\s?/)
        @member_emails.each do |member|
          @member = User.find_by_email(member.strip)
          if @member.nil?
            @invalid_members << member
          else
            @members << @member
          end
        end
      end

    #if user entered some communities add each community's users to @members
      if !params[:other_communities].nil?
        @communities = params[:other_communities].split(/[,;]\s?/)
        @communities.each do |communities|
          @other_community = Community.find_by_name(community)
          if @other_community.nil?
            @invalid_communities << community
          else
            @members = @members | @other_community.users
          end
        end
      end

      @community.approved = false

      respond_to do |format|
        if (@invalid_members.size > 0 or @invalid_communities.size > 0) or (@members.empty?)
          format.html{render 'communities/new/errors', :locals => {:invalid_members => @invalid_members, :invalid_communities => @invalid_communities, :members => @members}}
        else
          if @community.save
            #Create a new ballot for this community's creation
            @newcommunity_ballot = Ballot.new('content_id' => @community.id, 'over' => false, 'vote_type' => 'new_community', 'users' => @members, 'author_id' => current_user.id)
            @newcommunity_ballot.save
            @newcommunity_ballot.create_notification(:message => "New Community (#{@community.name}) 1/#{@members.count} votes", :finished => false)
            @community.ballots << @newcommunity_ballot
            #Set author ballot to true since they're the creator of the vote
            @author_vote = @newcommunity_ballot.votes.find_by_user_id(current_user.id)
            @author_vote.approval = true
            @author_vote.save
            @community.save
            format.html { redirect_to(communities_path, :notice => "You have created a community and it is now in the voting process") }
            format.xml  { render :xml => @community, :status => :created, :location => @community}
          else
            format.html { render :action => "new" }
            format.xml  { render :xml => @community.errors, :status => :unprocessable_entity }
          end
        end
      end
    end
  end

  # PUT /communities/1
  # PUT /communities/1.json
  def update
    if logged_in?
      @community = Community.find(params[:id])
      @edit_type = params[:edit_type]
      if @edit_type == 'add'
        @person = User.find_by_email(params[:add_person])
      elsif @edit_type == 'remove'
        @person = User.find_by_email(params[:remove_person])
      end
      #This is needed for the jQuery .submit() call
      @archive = params["archive_#{@community.id}".to_sym]
      @community.archived = @archive unless @archive.nil?
      @community.save

      #Don't let more than one vote per member occur
      if @edit_type == 'add' or @edit_type == 'remove'
        @community.ballots.each do |b|
          if b.member_id == @person.id and b.over == false
            redirect_to(community_path(@community), :notice => "There is already a vote in progress for " + @person.to_s)
            return
          end
        end
      end

      if @edit_type == 'add'
        if @person == current_user
          redirect_to(community_path(@community), :notice => "You can't add/remove yourself from the community!")
          return
        elsif @community.users.include?(@person)
          redirect_to(community_path(@community), :notice => params[:add_person] + " is already a member of this community.")
          return
        elsif @person.nil?
          redirect_to(community_path(@community), :notice => params[:add_person] + " does not exist.")
          return
        end
        #create a ballot for this member add; create votes for everyone including the person being invited
        @editcommunity_ballot = Ballot.new('content_id' => @community.id, 'over' => false,
          'vote_type' => 'add_community_member', 'users' => @community.users + [@person],
          'member_id' => @person.id, 'author_id' => current_user.id)
        @editcommunity_ballot.save
        @editcommunity_ballot.create_notification(:message => "Add Member (#{@community.name}) 1/#{@community.users.count+1} votes", :finished => false)
        @community.ballots << @editcommunity_ballot
        @community.save
      elsif @edit_type == 'remove'
        if @person == current_user
          redirect_to(community_path(@community), :notice => "You can't add/remove yourself from the community!")
          return
        elsif @community.voteable == false
          redirect_to(community_path(@community), :notice => "A remove member vote is currently in progress and must be resolved before starting another remove member vote.")
          return
        elsif @person.nil?
          redirect_to(community_path(@community), :notice => params[:remove_person] + " does not exist.")
          return
        elsif !@community.users.include?(@person)
          redirect_to(community_path(@community), :notice => params[:remove_person] + " is not a member of this community.")
          return
        end
        #create a ballot for this member removal; create votes for everyone but the current_user and the person we're removing
        @editcommunity_ballot = Ballot.new('content_id' => @community.id, 'over' => false,
          'vote_type' => 'remove_community_member', 'users' => @community.users - [@person],
          'member_id' => @person.id, 'author_id' => current_user.id)
        @editcommunity_ballot.save
        @editcommunity_ballot.create_notification(:message => "Remove Member (#{@community.name}) 1/#{@community.users.count-1} votes", :finished => false)
        @community.voteable = false
        @community.ballots << @editcommunity_ballot
        @community.save
      else
        #edit_type not found
      end

      if @edit_type == 'add' or @edit_type == 'remove'
        #The person starting the vote will have their vote set to True automatically
        @current_user_vote = Vote.find_by_user_id_and_ballot_id(current_user.id, @edittag_ballot.id)
        @current_user_vote.approval = true
        @current_user_vote.save
      end

      respond_to do |format|
        if @community.update_attributes(params[:community])
          format.html { redirect_to(@community, :notice => 'Community was successfully updated. If you added or removed a member, a vote is now in progress.') }
          format.xml  { head :ok }
        else
          format.html { render :action => "edit" }
          format.xml  { render :xml => @community.errors, :status => :unprocessable_entity }
        end
      end
    end
  end

  # DELETE /communities/1
  # DELETE /communities/1.json
  def destroy
    @community = Community.find(params[:id])
    @community.destroy

    respond_to do |format|
      format.html { redirect_to communities_url }
      format.json { head :no_content }
    end
  end

  #KJS: for 'community' concept
  def communityaction 
    case params[:theaction]
      when 'archive'
        Community.update_all(["archived=?", true], :id => params[:community_ids])
      when 'restore'
        Community.update_all(["archived=?", false], :id => params[:community_ids])
    end
    redirect_to communities_path
  end
end
