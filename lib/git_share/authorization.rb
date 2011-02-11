module GitShare
  module Authorization
    module Oauth
     
      APIS = { :twitter => "http://api.twitter.com" }
      CONSUMER_KEYS = { :twitter => Twitter::CONSUMER_KEY }
      CONSUMER_SECRETS = { :twitter => Twitter::CONSUMER_SECRET }

      class << self

        def consumer(network)
          options = {:site => APIS[network], :scheme => :header }
          proxy = ENV['http_proxy']
          if proxy && !proxy.empty?
            options[:proxy] = proxy
          end
          OAuth::Consumer.new( CONSUMER_KEYS[network], CONSUMER_SECRETS[network], options)
        end

        def authorize(request, pin, network )
          request_token = OAuth::RequestToken.new(consumer(network), request.token, request.secret)
          access_token = request_token.get_access_token(:oauth_verifier => pin)
          access_token
        end

        def generate_access_token(network, token, secret)
          token_hash = {:oauth_token => token, :oauth_token_secret => secret}
          OAuth::AccessToken.from_hash(consumer(network), token_hash )
        end

        def authorized?(access_token)
          oauth_response = access_token.get('/account/verify_credentials.json')
          return oauth_response.class == Net::HTTPOK
        end

        def add_user(user, access_token, network)
          Tokens.register(:network => network,
                                    :user => user,
                                    :key => access_token.token,
                                    :secret => access_token.secret)
        end
      end
    end
  end
end
