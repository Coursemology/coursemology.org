#!/usr/bin/env bash
# Simple move this file into your Rails `script` folder. Also make sure you `chmod +x puma.sh`.
# Please modify the CONSTANT variables to fit your configurations.

PUMA_CONFIG_FILE=config/puma.rb
PUMA_PID_FILE=tmp/pids/puma.pid
PUMA_SOCKET=tmp/sockets/puma.sock

. ~/.bash_profile

puma_is_running() {
  if [ -e $PUMA_PID_FILE ] ; then
    FILENAME=$PUMA_PID_FILE
    PID=0
    while read LINE
    do
      PID=$LINE
    done < $FILENAME

    if ps -p $PID > /dev/null
    then
      return 0
    else
      return 1
    fi
  else
    return 1
  fi
}

puma_high_memo() {
  echo "check memory usage"
  FILENAME=$PUMA_PID_FILE
  PID=0
  while read LINE
  do
    PID=$LINE
  done < $FILENAME

  t=$(ps -p $PID -o %mem)
  p=0
  for word in $t
  do
    p=$word
  done
  echo "mem $p%"
  
  if [ $(echo "$p > 40" | bc) -ne 0 ]  ; then
    return 0
  else
    return 1
  fi
}

rvm use ruby-2.2.2

if [ $# -gt 0 ]; then
  #clean memory
  if puma_is_running ; then
    if puma_high_memo ; then
      echo "we need to clean memo"
      pumactl -P $PUMA_PID_FILE restart
    else 
      echo "memory usage normal"
    fi
    exit 0
  fi
else
  #restart
  echo "we want to restart puma"

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
fi

puma --config $PUMA_CONFIG_FILE


