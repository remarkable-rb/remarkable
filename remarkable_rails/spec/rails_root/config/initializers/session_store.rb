# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :session_key => '__rails_root_session_id',
  :secret      => 'b8df1116410af84c4ca3d5ae95b87b56db00c40fb42e3742bfb039d9c247e1e67d035e1a20d53058267a582eec7808639f4eefca403ff9faafbc06c4414fc0ee'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
