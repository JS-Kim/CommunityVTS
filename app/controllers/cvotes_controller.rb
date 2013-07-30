class CvotesController < ApplicationController
  # GET /cvotes
  # GET /cvotes.json
  def index
    @cvotes = current_user.cvotes

    respond_to do |format|
      format.html # index.html.erb
    end
  end
  # GET /cvotes/1/edit
  def edit
    @cvote = Cvote.find(params[:id])
  end
 
  # PUT /cvotes/1
  # PUT /cvotes/1.json
 def update
    @cvote = Cvote.find(params[:id])
    if params[:vote_yes]
      @cvote.approval = true
    else
      @cvote.approval = false
    end
    # @approval = params["approval_#{@cvote.id}".to_sym]
    # @approval = params[:approval] if @approval.nil?

    # @cvote.approval = @approval unless @approval.nil?
    
    @cvote.save

    if @cvote.update_attributes(params[:cvote])
      if @cvote.approval
        @ballot = @cvote.ballot
        @community = Community.find(@ballot.content_id) #through annotations
        @community.users << User.find(current_user.id)
        @community.save
      end
      Ballot.vote_check(@cvote.ballot)
      respond_to do |format|
        #format.html { redirect_to(ballots_path, :notice => 'Vote successful') }
        format.html { redirect_to(ballots_path) }
      end
      
    end
  end

  def voteaction
    if params[:vote_yes] || params[:vote_no]
      update
      return #KJS: should provide this....avoiding double rendering
    end
    if params[:submit_yes]
      #debugger
        #puts "************ cvotes_controller: voteaction: yes"
        Cvote.update_all(["approval=?", true], :id => params[:cvote_ids])
        #KJS
        cvote_yes_ids = params[:cvote_ids]
        #update memberships....
        if params[:cvote_ids]
          cvote_yes_ids.each do |yes_id|
            @cvote = Cvote.find(yes_id)
            @ballot = @cvote.ballot
            @community = Community.find(@ballot.content_id) #through annotations
            @community.users << User.find(current_user.id)
            @community.save
          end
        end
    elsif params[:submit_no]
        Cvote.update_all(["approval=?", false], :id => params[:cvote_ids])
    end
    #need to call vote_check for all of the ballots we're voting on
    if params[:cvote_ids]
      cvote_ids = params[:cvote_ids]
      cvote_ids.each do |cvote_id|
        @cvote = Cvote.find(cvote_id)
        Ballot.vote_check(@cvote.ballot)
      end
    end
    redirect_to ballots_path
  end
end
