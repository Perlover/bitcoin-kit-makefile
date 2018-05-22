alias testnet-lncli="lncli --rpcserver localhost:10010"
alias mainnet-lncli="lncli --rpcserver localhost:10009"

alias lncli-web-start='cwd=`pwd`; cd $HOME/opt/lncli-web; ./start.sh ; cd $cwd'
alias lncli-web-stop='kill `cat $HOME/opt/lncli-web/server.pid`'
