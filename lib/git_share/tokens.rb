module GitShare
  module Tokens
  
    TOKENS_FILE =  File.join(File.dirname(__FILE__),'.tokens')
    
    class << self
      # Return a hash with tokens
      # tokens = read_tokens_file
      # tokens[:twitter][#{email}] = {:key => "x", :secret => "y"
      def read_tokens_file
        if (File.exists? TOKENS_FILE) && (File.readable? TOKENS_FILE)
          tokens_file = File.open(TOKENS_FILE)
          tokens = {}
          tokens[:twitter] = {}
          tokens_file.each_line do |line|
            line.chomp!
            network, user, key, secret = line.split('#')
            tokens[network.to_sym][user] = {:key => key, :secret => secret}
          end
          tokens_file.close
          tokens
        else
          nil
        end
      end

      def register(attrs)
        file = File.open(TOKENS_FILE)
        network = attrs[:network].to_s
        user = attrs[:user]
        already_registered = false
        tokens = []
        modify = -1
        file.each_with_index do |line, i|
          tokens << line
          if line.match /#{network}\##{user}\#*/
            already_registered = true
            modify = i
          end  
        end
        file.close

        if already_registered
          tokens[modify] = [network, user, attrs[:key], attrs[:secret]].join('#')
        else
          tokens << [network, user, attrs[:key], attrs[:secret]].join('#')
        end

        file = File.open(TOKENS_FILE, "w+")
        tokens.each {|token| file.puts token}
        file.close

        true
      end
    end
  end
end

