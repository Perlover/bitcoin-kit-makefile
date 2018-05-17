#!/bin/bash

cd $HOME/opt/lncli-web &&
if [ ! -f server.pid ]; then
    nohup node server --usetls ssl --user admin --pwd $$LNCLI_WEB_ADMIN_PASS$$ --limituser limit --limitpwd $$LNCLI_WEB_LIMIT_PASS$$ -h $$LISTEN_IP_ADDRESS$$ &>/dev/null &
    echo $! >server.pid
else
    echo 'lncli-web is already run (pid: '`cat server.pid`')'
fi
