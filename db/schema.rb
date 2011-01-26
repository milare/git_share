def create_clients
  ActiveRecord::Base.connection.instance_eval do
    create_table :clients do |t|
      t.string :twitter_username, :null => false
      t.string :twitter_oauth_token
      t.string :twitter_oauth_secret
      t.string :twitter_pin
    end
  end
end




