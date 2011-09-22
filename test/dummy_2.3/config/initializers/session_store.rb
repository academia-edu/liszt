# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_dummy_2.3_session',
  :secret      => '619392db010b8f2f53e05d969fddcf8fc241a5a6b16d084982f46c4c26d671ad3693435cef5272083db46d2c5ff962964ff643d14c3548bc2cb4086720c3b145'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
