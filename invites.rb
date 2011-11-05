#!/usr/bin/ruby

require 'rubygems'
require 'mail'
require 'yaml' # Should switch to 1.9.2 and psych

# load settings from settings.yaml
settings = YAML.load_file('settings.yml')

# get list of admins
admins = settings["admins"]

# read the already invited list
invited = File.readlines('invited.txt').collect! { |l| l.strip }

# create empty array to hold the list of people that subscribed with this run
subscribed = []

# create an empty array to hold people that we need to send emails to
new_invites = []

# configure POP3 client
Mail.defaults do
	delivery_method :smtp, :address => settings["host"],
						   :domain => settings["domain"],
						   :user_name => settings["username"],
					       :password => settings["password"],
						   :authentication => "plain",
						   :openssl_verify_mode => OpenSSL::SSL::VERIFY_NONE

						   retriever_method :pop3, :address => settings["host"],
							:user_name => settings["username"],
							:password => settings["password"]
end

# fetch all mail messages from the server
messages = Mail.all

# Iterate over messages and populate email lists
messages.each do |message|
	from_address = message.from.first
	if admins.index(from_address) != nil then
		# an admin sent an email with an email address in the title
		new_invites.push(message.subject.strip)
		invited.push(message.subject)
	elsif invited.index(from_address) != nil then
		# someone responded to an invitation email
		# remove them from invited and then add them to the subscribed list
		invited.delete(from_address)
		subscribed.push(from_address)
	end
end

# Send emails
new_invites.each do |address|
	message = Mail.new do
		from	settings["from_address"]
		to		address
		subject	settings["subject"]
		html_part do
			content_type 'text/html; charset=UTF-8'
			body 	File.read(settings["message"])
		end
	end
	message.deliver!
end

# Delete all of the messages
Mail.delete_all

# Write out invited list
invited_file = File.open("invited.txt", "w")
invited.each do |address| 
	invited_file.puts address
end
invited_file.close()

# Write out subscribed list
sub_file = File.open("subscribed.txt", "w")
subscribed.each do |address|
	sub_file.puts address
end
sub_file.close()

# Optionally run program to pick up new addresses
if settings["add_path"] != nil and subscribed.length > 0 then
	`#{settings["add_path"]}`
end

# And we're done!