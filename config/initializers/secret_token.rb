# Be sure to restart your server when you modify this file.

# Your secret key for verifying the integrity of signed cookies.
# If you change this key, all old signed cookies will become invalid!
# Make sure the secret is at least 30 characters and all random,
# no regular words or you'll be exposed to dictionary attacks.
Coursemology::Application.config.secret_token =
    if Rails.env.development? or Rails.env.test?
      '6646d49dfcbde9fd877fe9317c14d417a6d433e36b1694441029109af312b3dde6356f47b8b422389cabb8e9e65ac1c75ea8ebfa60b46b8708ff9945fa3f58e7'
    else
      ENV['APP_SECRET']
    end
