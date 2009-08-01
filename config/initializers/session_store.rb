# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_musikschule_session',
  :secret      => 'f9cfb44b4590988154f5bb5a47e8b1837b7d40ded99c905d2472a4b3c6110342440671cfe68c0608d9a00102d5b253d8d31eed118e373d05359fc301ace031e3'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
