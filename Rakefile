require 'rake'
require 'active_record'
require 'yaml'
require 'db/schema'

namespace :db do
  task :prepare => :environment do
    create_clients
  end
  
  task :create => :environment do
    ActiveRecord::Base.establish_connection(@config.merge('database' => nil))
    ActiveRecord::Base.connection.create_database(@config['database'])
    ActiveRecord::Base.establish_connection(@config)
  end
  
  task :drop => :environment do
    ActiveRecord::Base.establish_connection(@config)
    ActiveRecord::Base.connection.drop_database @config['database']
  end
  
  task :environment do
    config = YAML::load(File.open('config/database.yml'))
    if ((ENV["GIT_SHARE_ENV"]) && (['production', 'test'].include? ENV["GIT_SHARE_ENV"]))
      @config = config[ENV["GIT_SHARE_ENV"]]
    else
      @config = config["development"]
    end
    ActiveRecord::Base.establish_connection(@config)
    ActiveRecord::Base.logger = Logger.new(File.open('log/database.log', 'a+'))
  end
end

