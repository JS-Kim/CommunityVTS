class Community < ActiveRecord::Base
  validates :name, :presence => true, :uniqueness => true
  scope :archived_communities, :conditions => {:archived => true}
  scope :current_communities, :conditions => {:archived => false} #KSJ: ??

  #KJS: refer to CMail's tag.rb
  # for intersection of post, communities (tags), and users

  #KJS: ??
  def to_s
  	name
  end

  #KJS: refer to CMail's tag.rb

  has_many :memberships
  has_many :users, :through => :memberships, :uniq => true

  #has_many :ballots, :as => :myballots
end
