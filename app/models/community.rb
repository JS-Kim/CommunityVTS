class Community < ActiveRecord::Base
  attr_accessible :approved, :archived, :description, :name, :votable
end
