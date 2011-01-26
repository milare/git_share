class Client < ActiveRecord::Base

  def initialize(users)
    super(:twitter_username => users[:twitter])    
  end

  def request_twitter_authorization
      GitShare::Twitter::Authorization.request_authorization(self.twitter_username)
  end
  
  def tweet(text)
    if twitter_oauth_token && twitter_oauth_secret
      access_token = GitShare::Twitter::Authorization.generate_access_token(twitter_oauth_token, twitter_oauth_secret)
      if access_token
        begin
          access_token.request(:post,"http://api.twitter.com/1/statuses/update.xml",{'Content-Type' => 'application/xml','status' => text})
        rescue
          puts "Tweet not sent"
        end
      end
    else
      puts "You must request twitter authorization before tweet!"
    end
  end

end
