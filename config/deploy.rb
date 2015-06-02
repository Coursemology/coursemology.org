lock '3.2.1'

set :application, 'coursemology'

set :repo_url, 'git@github.com:coursemology/coursemology.org.git'
set :branch, 'development'
set :deploy_via, :remote_cache

set :linked_dirs, ['log', 'tmp/cache', 'tmp/sockets', 'tmp/pids']

namespace :deploy do
  after :finished, 'puma:restart'
end
