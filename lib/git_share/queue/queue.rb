module GitShare
  module Queue

    class << self

      def enqueue(attrs)
        network = attrs[:network]
        user = attrs[:username]
        message = attrs[:text]

        if network && user && message
          if !File.exists? QUEUE_FILE
            file = File.new(QUEUE_FILE, "w+")
          else
            file = File.open(QUEUE_FILE, "a+")
          end
          file.puts [network, user, message].join('|')
          file.close

          $LOG.info  "Message #{message} from #{user} has been enqueued."
        else
          $LOG.error "Error enqueing message #{message} from #{user}."
        end
      end

      def unqueue(quantity = :all)
        puts "Looking for #{QUEUE_FILE}...#{File.exists? QUEUE_FILE}"
        if File.exists? QUEUE_FILE
          file = File.open(QUEUE_FILE)
          items = file.readlines
          file.close
          if quantity == :all
            items.each do |raw_item|
              
              raw_item = items.first
              item = raw_item.split('|')
              network = item.shift
              user = item.shift
              message = item.shift

              if network && message && user
                if network == "twitter"
                  if GitShare::Twitter::Publish.tweet(user, message)
                    items.shift
                    puts "Tweet #{message.chomp} from #{user} sent!"
                    $LOG.info "Message #{message.chomp} from #{user} has been tweeted."
                  else
                    puts "Tweet #{message.chomp} from #{user} not sent."
                    $LOG.error "Error tweeting #{message.chomp} from #{user}."
                  end
                end
              end
            end
          end

          file = File.open(QUEUE_FILE,"w")
          items.each do |line|
            file.puts line
          end

        else
          $LOG.warn "No message to unqueue."
          puts "Nothing to be done."
        end
      end

      def reset!
        FileUtils.rm(QUEUE_FILE)        
      end

    end
  end
end
