class Client < ActiveRecord::Base

  class << self
    def request_twitter_authorization
      GitShare::Twitter::Authorization.request_authorization  
    end
  end

  def tweet(text)
    if self.serialized_access_token
      access_token = Marshal.load(self.serialized_access_token)
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
