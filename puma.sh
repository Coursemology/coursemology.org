#!/usr/bin/env bash
# Simple move this file into your Rails `script` folder. Also make sure you `chmod +x puma.sh`.
# Please modify the CONSTANT variables to fit your configurations.

PUMA_CONFIG_FILE=config/puma.rb
PUMA_PID_FILE=tmp/pids/puma.pid
PUMA_SOCKET=tmp/sockets/puma.sock

. ~/.bash_profile

puma_is_running() {
  if [ -e $PUMA_PID_FILE ] ; then
  return 0
  else
    return 1
    fi
    }

    if puma_is_running ; then
      echo "Hot-restarting puma..."
      pumactl -P $PUMA_PID_FILE restart

      echo "Doublechecking the process restart..."
      sleep 5
      if puma_is_running ; then
        echo "done"
        exit 0
      else
        echo "Puma restart failed :/"
        fi
        fi

        bundle exec puma --config $PUMA_CONFIG_FILE