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
[["bob@company.com", "bob", "Bob Tilford"], ["tom@company.com", "tom", "Tom Martin"], ["dan@company.com", "dan", "Dan McMillian"],
  ["john@company.com", "john", "John Pinnel"], ["sherley@company.com", "sherley", "Sherley Montano"], ["mary@company.com", "mary", "Mary Byford"],
  ["david@company.com", "david", "David Jones"], ["kristen@company.com", "kristen", "Kristen Scott"], ["susan@company.com", "susan", "Susan Williams"],
  ["jake@company.com", "jake", "Jake Williams"], ["jessie@company.com", "jessie", "Jessie Smith"], ["sarah@company.com", "sarah", "Sarah Thompson"], 
  ["brian@company.com", "brian", "Brian Caldwell"], ["allison@company.com", "allison", "Allison Watts"], ["michael@company.com", "michael", "Michael Brown"]].each do |u|
	if (User.where("email = ?", u[0]).empty?)
		User.new( :email => u[0], :login => u[1], :realname => u[2], :password => '123123' ).save!
	end
end
#For VTS Users
#rails console
#> User.all.each { |u| u.activate}
#> User.all.each { |u| u.make_activation_code; u.save} <== before this, comment 'protected' in User.rb


#["Human Resources", ["sarah@company.com", "jessie@company.com", "susan@company.com", "mary@company.com", "sherley@company.com", "david@company.com", "dan@company.com", "john@company.com"], "A community tag for all Human Resources correspondence"]
#Create communities and assign users
[["Corporate", ["michael@company.com","brian@company.com", "sarah@company.com", "bob@company.com", "tom@company.com", "dan@company.com", "john@company.com", "sherley@company.com", "mary@company.com", "david@company.com", "kristen@company.com", "susan@company.com", "jake@company.com", "jessie@company.com"], "Corporate-wide community"],
  ["Managers", ["jake@company.com", "jessie@company.com", "david@company.com", "sherley@company.com"], "Exclusive community used for managers"]].each do |community|
  @users = community[1].map{|u| User.find_by_email(u)}.compact
  Community.new(:name => community[0], :users => @users, :description => community[2], :approved => true).save!
end



puts 'Seeding finished'
