# Coursemology [![Build Status](https://travis-ci.org/Coursemology/coursemology.org.svg?branch=development)](https://travis-ci.org/Coursemology/coursemology.org) [![Coverage Status](https://coveralls.io/repos/Coursemology/coursemology.org/badge.png)](https://coveralls.io/r/Coursemology/coursemology.org) [![Gitter](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/Coursemology/coursemology.org?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)


<a href="http://coursemology.org"><img src="https://raw.githubusercontent.com/Coursemology/coursemology.org/development/public/images/coursemology_logo_landscape_100.png"
 alt="Coursemology logo" title="Coursemology" align="right" /></a>

Coursemology is an open source gamified learning platform that enables educators to increase student engagement and make learning fun.

## Setting up Coursemology

There are two ways to setup a local development instance of Coursemology. You can either use Vagrant and Ansible to automate the setup or you can do it manually.

### With Vagrant

#### Requirements

1. [VirtualBox](https://www.virtualbox.org/)
2. [Vagrant](https://www.vagrantup.com/)
3. [Ansible](http://docs.ansible.com/intro_installation.html)

#### Setting up

    cd coursemology.org
    vagrant up
    # Grab a cup of coffee

Once the virtual machine is provisioned, you may ssh into the virtual machine and start running the server.

    vagrant ssh
    cd coursemology
    rails s

### Manually without Vagrant

#### Requirements

1. Ruby and Ruby on Rails (3.2.14)
2. MySQL

Setting up a Ruby on Rails environment is pretty involved. You may follow the instructions on [GoRails](https://gorails.com/setup/osx/10.10-yosemite) for your own operating system.

#### Setting up

    cp .env_sample .env

    bundle install
    rake db:setup db:migrate db:populate_course_pref db:gen_fake_data
    rails s

## Testing on your local machine

A Superuser is added during `rake db:seed`.

    username: jfdi@academy.com
    password: supersecretpass

## Contributing

We love contributors!

1. Fork the repository.
2. Clone your fork to your machine.
3. `git checkout -b awesome-feature`
4. Make changes.
5. `git push origin awesome-feature`
6. Create a pull request on github.

## Contact Us

Have an idea? Pop by the [gitter](https://gitter.im/Coursemology/coursemology.org) chat room. If you prefer emails, join us at the [Coursemology-Dev](https://groups.google.com/forum/#!forum/coursemology-dev) mailing list. We will respond to you in less than 24 hours unless there's a zombie apocalypse.

## Found Boogs?

Create an issue on the Github [issue tracker](https://github.com/Coursemology/coursemology.org/issues).

## License

Copyright (c) 2013-2016 Coursemology.org. This software is licensed under the MIT License.

## Acknowledgments

The Coursemology.org Project was made possible by a number of teaching development grants from the National University of Singapore over the years. 
