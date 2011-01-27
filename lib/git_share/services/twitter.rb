module GitShare
  module Twitter

    module Authorization
      
      class << self

        def consumer
          options = {:site => "http://api.twitter.com", :scheme => :header }
          proxy = ENV['http_proxy']
          if proxy && !proxy.empty?
            options[:request_endpoint] = proxy
          end
          OAuth::Consumer.new( CONSUMER_KEY, CONSUMER_SECRET, options)
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

        def request_authorization
          request_token = consumer.get_request_token
          puts "Twitter Authorization"
          puts "Type the following URL in your browser:"
          puts request_token.authorize_url
          puts "Type the PIN number:"
          pin = STDIN.gets.chomp
          puts "Registering PIN..."
          access_token = authorize(request_token, pin)

          if (authorized? access_token) && (client = register_client(access_token, pin))
            puts "Client registered successfully!"
            client
          else
            puts "Client not registered, try again!"
            nil
          end
        end

        def register_client(access_token, pin)
          config = GitShare.read_config_file
          if config && config['twitter'] && config['twitter']['username']
            username = config['twitter']['username']
            if username && !username.empty?
              client = Client.find(:first, :conditions => { :twitter_username => username })
              if client
                client.update_attributes(:twitter_oauth_token => access_token.token,
                                         :twitter_oauth_secret => access_token.secret,
                                         :twitter_pin => pin)
              else
                client = Client.new(:twitter_username => username,
                           :twitter_oauth_token => access_token.token,
                           :twitter_oauth_secret => access_token.secret,
                           :twitter_pin => pin)
                client.save
              end
              client
            else
              puts "Check you config file, maybe the twitter username is blank."
              nil
            end
          else
            puts "Configuration cannot be found."
            nil
          end
        end
      end
    end
  end
end

