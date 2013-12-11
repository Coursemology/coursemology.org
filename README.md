# Introduction

Coursemology, an open source online education platform for school :-)

# Quick Start
To get started, you will need to do the following:

    1. Clone the repository
    2. Created a Facebook app and retrive it `App ID` and `App secret`

## Setting up

    $ cp sample_config/facebook.yml.sample config/facebook.yml
    # Edit the file to use your own Facebook App ID and secret

    $ cp sample_config/devise_initializer.rb.sample config/initializers/devise.rb
    # Edit the file (mailer_sender, omniauth)

    # Set 2 environment variables: GMAIL_SMTP_USER and GMAIL_SMTP_PASSWORD
    # either just run this commands or add them into a .rvmrc file
    $ export GMAIL_SMTP_USER='your_email@gmail.com'
    $ export GMAIL_SMTP_PASSWORD='your_password'

    $ bundle install
    $ rake db:create # Do it for the first time
    $ rake db:schema:load
    $ rake db:seed
    $ rake db:gen_fake_data # Creates sample courses & users for you, takes a few minutes
                            # after more changes in future, run rake db:migrate

    # The app performance can be monitored by adding newrelic config file:
    # config/newrelic.yml

# Testing on your local machine

One Superuser is added during `rake db:seed`.

    username: jfdi@academy.com
    password: supersecretpass

# Checking available API / routes:
    $ rake routes

# Self deploying Rails apps with Phusion Messenger

In case you are trying to deploy the website yourself using Passenger (aka mod_rails), here is a good guide to get started:

    http://www.web-l.nl/posts/5

# Third party libraries

You should skim through the README of these following gems to get a gist of how they works

* Authentication: [Devise](https://github.com/plataformatec/devise)
* Authorization: [CanCan](https://github.com/ryanb/cancan)
* Front-end Framework/library: [Bootstrap](http://twitter.github.com/bootstrap/) and [bootstrap-sass](https://github.com/thomas-mcdonald/bootstrap-sass)
* File upload: [Paperclip](https://github.com/thoughtbot/paperclip) (Very easy to use)
* Icon: [Font Awesome](http://fortawesome.github.com/Font-Awesome/) and [font-awesome-sass-rails](https://github.com/littlebtc/font-awesome-sass-rails)
* Datepicker: [Bootstrap Datepicker for Rails](https://github.com/Nerian/bootstrap-datepicker-rails)
