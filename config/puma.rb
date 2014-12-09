#!/usr/bin/env puma

# app do |env|
#   puts env
#
#   body = 'Hello, World!'
#
#   [200, { 'Content-Type' => 'text/plain', 'Content-Length' => body.length.to_s }, [body]]
# end

environment 'production'

stdout_redirect 'log/puma.log', 'log/puma_err.log'

# quiet
threads Integer(ENV['MIN_THREADS'] || 1), Integer(ENV['MAX_THREADS'] || 20)
bind 'unix:///tmp/coursemology_puma.sock'

# ssl_bind '127.0.0.1', '9292', { key: path_to_key, cert: path_to_cert }

# on_restart do
#   puts 'On restart...'
# end

# restart_command '/u/app/lolcat/bin/restart_puma'


# === Cluster mode ===

workers 2
# on_worker_boot do
#   puts 'On worker boot...'
# end

# === Puma control rack application ===

activate_control_app 'unix:///tmp/coursemology_pumactl.sock'

preload_app!
