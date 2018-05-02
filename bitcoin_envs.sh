export PATH=$HOME/bin:$PATH
export LD_LIBRARY_PATH="$HOME/lib:$HOME/lib64:/lib64:/usr/lib64:/usr/local/lib64"
export LD_RUN_PATH=$LD_LIBRARY_PATH
export LIBRARY_PATH=$LD_LIBRARY_PATH
export MANPATH="$HOME/share/man:$MANPATH"
export CPPFLAGS="-I$HOME/include"
export LDFLAGS="-L$HOME/lib -L$HOME/lib64 -L/lib64 -L/usr/lib64 -L/usr/local/lib64"
export PKG_CONFIG_PATH="$HOME/lib/pkgconfig:$HOME/lib64/pkgconfig"

if [ -f /etc/pki/ca-trust/extracted/openssl/ca-bundle.trust.crt ]; then
    export SSL_CERT_FILE=/etc/pki/ca-trust/extracted/openssl/ca-bundle.trust.crt
elif [ -f /etc/ssl/certs/ca-certificates.crt ]; then
    export SSL_CERT_FILE=/etc/ssl/certs/ca-certificates.crt
fi
