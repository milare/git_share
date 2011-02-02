module GitShare
  module Twitter

    module Authorization
       
      TWITTER_API = "http://api.twitter.com"
      class << self

        def consumer
          options = {:site => TWITTER_API, :scheme => :header }
          proxy = ENV['http_proxy']
          if proxy && !proxy.empty?
            options[:proxy] = proxy
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

        def request_authorization(user)
          request_token = consumer.get_request_token
          puts "Twitter Authorization"
          puts "Type the following URL in your browser:"
          puts request_token.authorize_url
          puts "Type the PIN number:"
          pin = STDIN.gets.chomp
          puts "Registering PIN..."
          access_token = authorize(request_token, pin)

          if (authorized? access_token) && (add_user(user, access_token))
            puts "User #{user} registered successfully!"
            true
          else
            puts "User #{user} not registered, try again!"
            nil
          end
        end

        def add_user(user, access_token)
          GitShare::Tokens.register(:network => :twitter,
                                    :user => user,
                                    :key => access_token.token,
                                    :secret => access_token.secret)
        end
      end
    end

    module Publish

      UPDATE_URL = "http://api.twitter.com/1/statuses/update.xml"

      class << self

        def tweet(user, text)
          tokens = GitShare::Tokens.read_tokens_file

          if tokens && tokens[:twitter] && tokens[:twitter][user]
            user_token = tokens[:twitter][user]
          
            if user_token[:key] && user_token[:secret]
              access_token = Authorization.generate_access_token(user_token[:key], user_token[:secret])
          
              if access_token
                begin
                  token = access_token.request(:post, UPDATE_URL,{'Content-Type' => 'application/xml','status' => text})
                  if token.class == Net::HTTPUnauthorized
                    puts "Your twitter token has expired, to request a new one ..."
                    puts "run: /usr/bin/ruby .git/git_share.rb register_twitter foo@bar.com"
                  else
                    puts "Tweet sent!"
                  end
                rescue
                  puts "Tweet not sent"
                end
              end
            end
          else
            puts "We dont have twitter authorization."
            puts "run: /usr/bin/ruby .git/git_share.rb register_twitter foo@bar.com"
          end
        end
      end
    end


  end
end

