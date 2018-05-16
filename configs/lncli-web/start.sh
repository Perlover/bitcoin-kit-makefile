#!/bin/sh

cd $HOME/opt/lncli-web &&
nohup node server --usetls ssl --user admin --pwd $$LNCLI_WEB_ADMIN_PASS$$ --limituser limit --limitpwd $$LNCLI_WEB_LIMIT_PASS$$ -h $$EXTERNAL_IP_ADDRESS$$ &>/dev/null &
