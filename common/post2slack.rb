require 'uri'
require 'net/http'
require 'json'

def post2slack(message, post_url)
    payload = {
        text: message
    }.to_json

    uri = URI.parse(post_url)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true

    request = Net::HTTP::Post.new(uri.request_uri)
    request.content_type = 'application/json'
    request.body = payload

    response = http.request(request)
    puts response.body
end
