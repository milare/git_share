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

          if (authorized? access_token) && (register_client(access_token))
            puts "Client registered successfully!"
          else
            puts "Client not registered, try again!"
          end
        end

        def register_client(access_token)
          config = GitShare.read_config_file
          if config && config['twitter'] && config['twitter']['username']
            username = config['twitter']['username']
            client = Client.find(:first, :conditions => { :username => username })
            if client
              client.update_attributes(:serialized_access_token => Marshal.dump(access_token))
            else
              client = Client.new(:username => username, :serialized_access_token => Marshal.dump(access_token))
              return false if !client.save
            end
            true
          else
            false
          end
        end

      end

    end
  end
end

