class Cvote < ActiveRecord::Base
  attr_accessible :approval, :ballot_id, :user_id
end
