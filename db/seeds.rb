# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Mayor.create(:name => 'Daley', :city => cities.first)
User.delete_all
Community.delete_all
Ballot.delete_all
Cvote.delete_all
Notification.delete_all

#Create users
[["bob@company.com", "Bob Tilford"], ["tom@company.com", "Tom Martin"], ["dan@company.com","Dan McMillian"],
  ["john@company.com", "John Pinnel"], ["sherley@company.com", "Sherley Montano"], ["mary@company.com","Mary Byford"],
  ["david@company.com", "David Jones"], ["kristen@company.com", "Kristen Scott"], ["susan@company.com", "Susan Williams"],
  ["jake@company.com", "Jake Williams"], ["jessie@company.com", "Jessie Smith"], ["sarah@company.com", "Sarah Thompson"], 
  ["brian@company.com", "Brian Caldwell"], ["allison@company.com", "Allison Watts"], ["michael@company.com", "Michael Brown"]].each do |u|
	if (User.where("email = ?", u[0]).empty?)
		User.new( :email => u[0], :name => u[1], :password => '123123', :password_confirmation => '123123' ).save!
	end
end
#["Human Resources", ["sarah@company.com", "jessie@company.com", "susan@company.com", "mary@company.com", "sherley@company.com", "david@company.com", "dan@company.com", "john@company.com"], "A community tag for all Human Resources correspondence"]
#Create communities and assign users
[["Corporate", ["michael@company.com","brian@company.com", "sarah@company.com", "bob@company.com", "tom@company.com", "dan@company.com", "john@company.com", "sherley@company.com", "mary@company.com", "david@company.com", "kristen@company.com", "susan@company.com", "jake@company.com", "jessie@company.com"], "Corporate-wide community"],
  ["Managers", ["jake@company.com", "jessie@company.com", "david@company.com", "sherley@company.com"], "Exclusive community used for managers"]].each do |community|
  @users = community[1].map{|u| User.find_by_email(u)}.compact
  Community.new(:name => community[0], :users => @users, :description => community[2], :approved => true).save!
end



puts 'Seeding finished'
