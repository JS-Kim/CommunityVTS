class Membership < ActiveRecord::Base
  belongs_to :community_id 
  belongs_to :user_id
end
