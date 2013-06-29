class Ballot < ActiveRecord::Base
  attr_accessible :author_id, :content_id, :member_id, :myballots_id, :myballots_type, :outcome, :over, :vote_type
end
