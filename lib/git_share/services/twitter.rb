module GitShare
  module Twitter

    module Publish
      UPDATE_URL = "http://api.twitter.com/1/statuses/update.xml"

      class << self

        def tweet(user, text)

          if text.match /#(.)?t/
            text = text[0...135]
            tokens = GitShare::Tokens.read_tokens_file

            if tokens && tokens[:twitter] && tokens[:twitter][user]
              user_token = tokens[:twitter][user]
            
              if user_token[:key] && user_token[:secret]
                access_token = GitShare::Authorization::Oauth.generate_access_token(:twitter,user_token[:key], user_token[:secret])
            
                if access_token
                  begin
                    token = access_token.request(:post, UPDATE_URL,{'Content-Type' => 'application/xml','status' => text})
                    if token.class == Net::HTTPUnauthorized
                      puts "Your twitter token has expired, to request a new one ..."
                      puts "run:\n/usr/bin/ruby .git/git_share.rb register twitter foo@bar.com"
                      puts "Enqueuing your message ..."
                      $LOG.error "Token expired for #{text} from #{user}."
                      Queue.enqueue(:network => 'twitter', :username => user, :text => text)
                    else
                      puts "Tweet has been sent!"
                      $LOG.info "Tweet #{text} from #{user} has been sent."
                      return true
                    end
                  rescue Exception => e
                    Queue.enqueue(:network => 'twitter', :username => user, :text => text)
                    $LOG.error "Tweet #{text} from #{user} not sent, #{e}"
                    puts "Tweet not sent"
                  end
                end
              end
            else
              puts "We dont have twitter authorization."
              puts "Your message is enqueued, and will be sent when we have your authorization."
              puts "run the following command to request authorization:"
              puts "/usr/bin/ruby .git/git_share.rb register twitter foo@bar.com"
              $LOG.error "Tweet #{text} from #{user} not sent, missing token."
              Queue.enqueue(:network => 'twitter', :username => user, :text => text)
            end
          end
          false
        end
      end
    end

    class << self 
      def request_authorization(user)
        request_token = Authorization::Oauth.consumer(:twitter).get_request_token
        puts "Twitter Authorization"
        puts "Type the following URL in your browser:"
        puts request_token.authorize_url
        puts "Type the PIN number:"
        pin = STDIN.gets.chomp
        puts "Registering PIN..."
        access_token = Authorization::Oauth.authorize(request_token, pin, :twitter)

        if (Authorization::Oauth.authorized? access_token) && 
           (Authorization::Oauth.add_user(user, access_token, :twitter))
          puts "User #{user} registered successfully!"
          $LOG.info "#{user} registered."
          true
        else
          puts "User #{user} not registered, try again!"
          $LOG.error "#{user} not registered."
          nil
        end
      end
    end
  end
end

