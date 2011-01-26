require 'rubygems'
require 'oauth'
require 'yaml'
require 'active_record'
require 'ruby-debug'
require File.join(File.dirname(__FILE__), 'git_share', 'services', 'twitter')
require File.join(File.dirname(__FILE__), 'git_share', 'client')

module GitShare

  SERVICES_CONFIGURATION_PATH =  File.join(File.dirname(__FILE__),'..','config','services.yml')
  DB_CONFIGURATION_PATH =  File.join(File.dirname(__FILE__),'..','config','database.yml')

  class << self
    def read_config_file
      config = YAML::load(File.open(GitShare::SERVICES_CONFIGURATION_PATH))
      config ? config : nil 
    end
  end

  module Twitter
    CONSUMER_KEY = ENV['CONSUMER_KEY']
    CONSUMER_SECRET = ENV['CONSUMER_SECRET']
  end


  module Database
    class << self
      def connect!
        config = YAML::load(File.open(GitShare::DB_CONFIGURATION_PATH))
        if ((ENV["GIT_SHARE_ENV"]) && (['production', 'test'].include? ENV["GIT_SHARE_ENV"]))
          config = config[ENV["GIT_SHARE_ENV"]]
        else
          config = config["development"]
        end
        ActiveRecord::Base.establish_connection(config)
      end
    end
  end

  Database.connect! 

end
