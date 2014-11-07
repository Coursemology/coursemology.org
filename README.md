# Coursemology [![Build Status](https://travis-ci.org/Coursemology/coursemology.org.svg?branch=development)](https://travis-ci.org/Coursemology/coursemology.org) [![Coverage Status](https://coveralls.io/repos/Coursemology/coursemology.org/badge.png)](https://coveralls.io/r/Coursemology/coursemology.org)

# Introduction

Coursemology, an open source online education platform for schools :-)

# Quick Start
To get started, you will need to do the following:

 1. Clone the repository
 2. Create a [Facebook app][1] and retrieve its `App ID` and `App secret`
 3. Install [rvm][2] and install ruby 1.9.3
 4. Install mysql

## Setting up

    $ cp sample_config/facebook.yml.sample config/facebook.yml
    # Edit the file to use your own Facebook App ID and secret

    $ cp sample_config/devise_initializer.rb.sample config/initializers/devise.rb
    # Edit the file (mailer_sender, omniauth)

    $ cp config/database.yml.sample config/database.yml
    # Change the username and password in the development section as appropriate

    # Set 2 environment variables: GMAIL_SMTP_USER and GMAIL_SMTP_PASSWORD
    # either just run this commands or add them into a .rvmrc file
    $ export GMAIL_SMTP_USER='your_email@gmail.com'
    $ export GMAIL_SMTP_PASSWORD='your_password'

    $ bundle install
    $ rake db:create # Do it for the first time
    $ rake db:schema:load
    $ rake db:seed
    $ rake db:populate_course_pref
    $ rake db:gen_fake_data # Creates sample courses & users for you, takes a few minutes

    # The app performance can be monitored by adding newrelic config file:
    # config/newrelic.yml

## `clockwork` and `delayed_job`

Coursemology has got various tasks that need to be run at various intervals; the `clockwork` and `delayed_job` gems are used for this purpose. These need setting up to run alongside your application instance.

Run these tasks from your source checkout directory when your application is launched

    $ script/delayed_job start
    $ clockworkd -c lib/clock.rb --pid-dir=tmp/pids start

To terminate them (for upgrading or reloading)

    $ script/delayed_job stop
    $ clockworkd -c lib/clock.rb --pid-dir=tmp/pids stop

## Testing on your local machine

One Superuser is added during `rake db:seed`.

    username: jfdi@academy.com
    password: supersecretpass

The application can be started using `rails server` (using WeBrick) or `puma` (recommended for parallelisation.)

## Checking available API / routes:
    $ rake routes

# Production builds

Coursemology utilises the Rails assets pipeline. Also, changes might require schema migrations. Run them all on your deployment servers using the following comments

    $ rake db:migrate db:seed db:populate_course_pref
    $ rake tmp:cache:clear assets:clean:all assets:precompile:all

## Deploying Rails apps with Phusion Messenger

In case you are trying to deploy the website yourself using Passenger (aka mod_rails), here is a good guide to get started:

    http://www.web-l.nl/posts/5

## Windows Specific

If you are deploying/developing on Windows, you will need to compile some gems from source using the Ruby DevKit. The following gems require special attention:

 - mysql2 requires the MySQL C Connector to be present. Specify the path when installing the gem using `gem install mysql2 --version 0.3.13 -- --with-mysql-dir=.\mysql-connector-c-6.1.3-win32`
 - [Puma](https://github.com/puma/puma/issues/341) requires additional build resources not found within the DevKit. Notably, OpenSSL is missing. Obtain OpenSSL from the URL within the ticket and recompile.

Furthermore, it is good to have [Node.js](http://nodejs.org) installed for the assets pipeline to work. In theory, the asset pipeline can work with `cscript`, but it is known to not produce any output at least on Windows 8.1.

# Third party libraries

You should skim through the README of these following gems to get a gist of how they work.

* Authentication: [Devise](https://github.com/plataformatec/devise)
* Authorization: [CanCan](https://github.com/ryanb/cancan)
* Front-end Framework/library: [Bootstrap](http://twitter.github.com/bootstrap/) and [bootstrap-sass](https://github.com/thomas-mcdonald/bootstrap-sass)
* File upload: [Paperclip](https://github.com/thoughtbot/paperclip) (Very easy to use)
* Icon: [Font Awesome](http://fortawesome.github.com/Font-Awesome/) and [font-awesome-sass-rails](https://github.com/littlebtc/font-awesome-sass-rails)
* Datepicker: [Bootstrap Datepicker for Rails](https://github.com/Nerian/bootstrap-datepicker-rails)

[1]: https://developers.facebook.com/apps    "Facebook Apps"
[2]: https://rvm.io/                         "Ruby Version Manager"
