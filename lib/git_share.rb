require 'rubygems'
require 'oauth'
require File.join(File.dirname(__FILE__), 'git_share', 'services', 'twitter')
require File.join(File.dirname(__FILE__), 'git_share', 'tokens')
module GitShare
  module Twitter
    CONSUMER_KEY = ENV['CONSUMER_KEY']
    CONSUMER_SECRET = ENV['CONSUMER_SECRET']
  end
end

user = ARGV[0]
message = ARGV[1...ARGV.size].join(' ')

if user && message
  GitShare::Twitter::Publish.tweet(user, message)
end
