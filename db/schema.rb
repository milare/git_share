def create_clients
  ActiveRecord::Base.connection.instance_eval do
    create_table :clients do |t|
      t.string :username, :null => false
      t.text   :serialized_access_token
    end
  end
end




