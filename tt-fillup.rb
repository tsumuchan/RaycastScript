#!/usr/bin/env ruby

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title tt fillup
# @raycast.mode compact

# Optional parameters:
# @raycast.icon 🤖
# @raycast.argument1 { "type": "text", "placeholder": "description" }

# Documentation:
# @raycast.author tsumuchan

require 'net/http'
require 'uri'
require 'json'
require 'time'
require 'dotenv'

Dotenv.load

# Toggl API Key
API_KEY = ENV['TOGGL_API_KEY']

# Toggl API endpoint URLs
API_BASE_URL = 'https://api.track.toggl.com/api/v9'

description = ARGV[0]

# Get the current user's information
def get_user_info
  uri = URI.parse("#{API_BASE_URL}/me")
  request = Net::HTTP::Get.new(uri)
  request.basic_auth(API_KEY, 'api_token')
  response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
    http.request(request)
  end
  JSON.parse(response.body)
end

# Get the most recent time entry
def get_last_time_entry
  uri = URI.parse("#{API_BASE_URL}/me/time_entries")
  request = Net::HTTP::Get.new(uri)
  request.basic_auth(API_KEY, 'api_token')
  response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
    http.request(request)
  end
  # puts response.body
  time_entries = JSON.parse(response.body)
  time_entries.first
end

# Get the end time of the most recent time entry
def get_last_end_time
  last_time_entry = get_last_time_entry
  last_time_entry['stop']
end

# Create a new time entry with a specified duration
def create_time_entry_with_duration(description, duration, workspace_id)
  start_time = (Time.now - duration).iso8601
  end_time = Time.now.iso8601
  data = {
      'workspace_id' => workspace_id,
      'description' => description,
      'start' => start_time,
      'stop' => end_time,
      'duration' => duration,
      'created_with' => 'Toggl API By Raycast',
  }
  uri = URI.parse(API_BASE_URL + "/workspaces/#{workspace_id}/time_entries")
  request = Net::HTTP::Post.new(uri)
  request.basic_auth(API_KEY, 'api_token')
  request.body = data.to_json
  request['Content-Type'] = 'application/json'
  response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
    http.request(request)
  end
  # puts JSON.parse(response.body)
end

# main
user_info = get_user_info

last_end_time = get_last_end_time
if last_end_time
  duration = (Time.now - Time.parse(last_end_time)).to_i
else
  duration = 0
end

puts "Last time entry ended at: #{last_end_time}"
puts "Duration since last time entry: #{duration} seconds"

if duration > 0
  new_time_entry = create_time_entry_with_duration(description, duration, user_info['default_workspace_id'])
  puts "New time entry 「#{description}」 created with duration of #{duration} seconds"
end