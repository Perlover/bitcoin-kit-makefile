export PATH=$HOME/.npm-global/bin:$HOME/bin:$PATH

# man ld.so(8) - run time execution (not link time)
export LD_LIBRARY_PATH="$HOME/lib:$HOME/lib64:/lib64:/usr/lib64:/usr/local/lib64"

# ld uses it in link time
export LD_RUN_PATH=$LD_LIBRARY_PATH

# man gcc(1)
export LIBRARY_PATH=$LD_LIBRARY_PATH
export CPATH="$HOME/include"

export MANPATH="$HOME/share/man:$MANPATH"
export PKG_CONFIG_PATH="$HOME/lib/pkgconfig:$HOME/lib64/pkgconfig"

# TODEL these are only make variable
# export CPPFLAGS="-I$HOME/include"
# export LDFLAGS="-L$HOME/lib -L$HOME/lib64 -L/lib64 -L/usr/lib64 -L/usr/local/lib64"

if [ -f /etc/pki/ca-trust/extracted/openssl/ca-bundle.trust.crt ]; then
    export SSL_CERT_FILE=/etc/pki/ca-trust/extracted/openssl/ca-bundle.trust.crt
elif [ -f /etc/ssl/certs/ca-certificates.crt ]; then
    export SSL_CERT_FILE=/etc/ssl/certs/ca-certificates.crt
fi
