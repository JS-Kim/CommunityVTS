class Membership < ActiveRecord::Base
  belongs_to :community
  belongs_to :user
  # attr_accessible :title, :body
end
