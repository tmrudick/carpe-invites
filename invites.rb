#!/usr/bin/ruby

require 'rubygems'
require 'mail'
require 'yaml' # Should switch to 1.9.2 and psych

# load settings from settings.yaml
settings = YAML.load_file('settings.yaml')

# get list of admins
admins = settings["admins"]

# read the already invited list
invited = File.readlines('invited.txt')

# Create empty array to hold the list of people that subscribed with this run
subscribed = []

# configure POP3 client
Mail.defaults do
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
		puts message.subject
	elsif invited.index(from_address) != nil then
		invited.delete(from_address)
		subscribed.push(from_address)
	end
end