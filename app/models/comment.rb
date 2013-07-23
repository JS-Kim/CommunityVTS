class Comment < ActiveRecord::Base
  
  #KJS: for nested comments
  has_ancestry
  attr_accessible :body, :parent_id, :commentable_id, :commentable_type
  belongs_to :commentable, :polymorphic => true
  
  validates_presence_of :body

  belongs_to :user
  belongs_to :story
  # todo: why is this not working?
  has_one :activity_item, :dependent => :destroy

  def self.find_by_user(user_id, limit=5)
    find :all,
    :order => "created_at DESC",
    :conditions => {:user_id => user_id},
    :limit => limit
  end
end
