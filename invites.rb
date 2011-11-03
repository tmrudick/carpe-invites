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

messages.each do |message|
	if admins.index(message.from.to_s()) != nil then
		puts message.subject
	elsif invited.index(message.from.to_s()) != nil then
		invited.delete(message.from.to_s())
		subscribed.push(message.from.to_s())
	end
end