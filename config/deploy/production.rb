user = 'raymoond'
hostname = 'coursemology.org'

server hostname, user: user, roles: %w{web app db}, primary: true

set :rails_env, 'production'
