module GitShare
  module Twitter

    module Authorization
      
      class << self

        def consumer
          OAuth::Consumer.new( CONSUMER_KEY, CONSUMER_SECRET,{:site => "http://api.twitter.com", :scheme => :header })
        end

        def authorize(request, pin)
          request_token = OAuth::RequestToken.new(consumer, request.token, request.secret)
          access_token = request_token.get_access_token(:oauth_verifier => pin)
          access_token
        end

        def generate_access_token(token, secret)
          token_hash = {:oauth_token => token, :oauth_token_secret => secret}
          OAuth::AccessToken.from_hash(consumer, token_hash )
        end

        def authorized?(access_token)
          oauth_response = access_token.get('/account/verify_credentials.json')
          return oauth_response.class == Net::HTTPOK
        end

        def request_authorization(username)
          request_token = consumer.get_request_token
          puts "Twitter Authorization"
          puts "Type the following URL in your browser:"
          puts request_token.authorize_url
          puts "Type the PIN number:"
          pin = STDIN.gets.chomp
          puts "Registering PIN..."
          access_token = authorize(request_token, pin)

          if (authorized? access_token) && (register_client(username, access_token, pin))
            puts "Client registered successfully!"
          else
            puts "Client not registered, try again!"
          end
        end

        def register_client(username, access_token, pin)
          client = Client.find(:first, :conditions => { :twitter_username => username })
          if client
            client.update_attributes(:twitter_oauth_token => access_token.token,
                                     :twitter_oauth_secret => access_token.secret,
                                     :twitter_pin => pin)
          else
            false
          end
        end
      end
    end
  end
end

