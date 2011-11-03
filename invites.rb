#!/usr/bin/ruby

require 'rubygems'
require 'mail'
require 'yaml' # Should switch to 1.9.2 and psych

# load settings from settings.yaml
settings = YAML.load_file('settings.yaml')

puts settings["host"]