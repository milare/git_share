require 'rubygems'
require 'oauth'
require 'ruby-debug'
require 'logger'


module GitShare

  # Logger stuff
  LOG_FILE = File.expand_path(File.join(File.dirname(__FILE__), 'log', 'git_share.log'))
  if File.exists? LOG_FILE
    file = File.open(LOG_FILE, File::WRONLY | File::APPEND)
  else
    file = File.new(LOG_FILE, File::WRONLY | File::APPEND | File::CREAT)
  end
  $LOG = Logger.new(file, 'monthly')
  # End Logger stuff
  

  module Twitter
    CONSUMER_KEY = ENV['CONSUMER_KEY']
    CONSUMER_SECRET = ENV['CONSUMER_SECRET']

    $LOG.debug "Twitter CONSUMER_KEY=#{CONSUMER_KEY}"
    $LOG.debug "Twitter CONSUMER_SECRET=#{CONSUMER_KEY}"
  end

  module Queue
    PROCESS_QUEUE_FILE = File.expand_path(File.join(File.dirname(__FILE__), 'git_share', 'queue', 'process.rb'))
    QUEUE_FILE = File.expand_path(File.join(File.dirname(__FILE__), 'git_share', 'queue', '.queue'))
  end
end

require File.join(File.dirname(__FILE__), 'git_share', 'services', 'twitter')
require File.join(File.dirname(__FILE__), 'git_share', 'tokens')
require File.join(File.dirname(__FILE__), 'git_share', 'authorization')
require File.join(File.dirname(__FILE__), 'git_share', 'queue', 'queue')


if ARGV[0] == "register"
  if ARGV[1] == "twitter"
    user = ARGV[2]
    GitShare::Twitter.request_authorization(user)
  else
    puts "Usage: ruby .git/git_share.rb register <network> <email>"
  end

elsif ARGV[0] == "send"

  if ARGV[1] == "tweet"
    user = ARGV[2]
    message = ARGV[3...ARGV.size].join(' ')
    if user && message
      GitShare::Twitter::Publish.tweet(user, message)
    end
  else
    puts "Usage: ruby .git/git_share.rb send tweet <email> <message>"
  end
end
