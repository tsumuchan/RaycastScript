#!/usr/bin/env ruby

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title times
# @raycast.mode compact

# Optional parameters:
# @raycast.icon 🤖
# @raycast.argument1 { "type": "text", "placeholder": "Placeholder" }

# Documentation:
# @raycast.author tsumuchan

require './common/post2slack.rb'
require 'dotenv'

Dotenv.load

message = ARGV[0]
post_url = ENV['SLACK_WEBHOOK_TIMES']

post2slack(message, post_url)
