#!/bin/bash

NAME=$1
SITES="$HOME/sites"

if [ ! -d $SITES/$NAME/web ]
then
  echo "Error: Directory $SITES/$NAME/web does not exist."
  exit 1
fi

OUT=`mktemp`
TMP=`mktemp`
CRT="/etc/ssl/private/$NAME.crt"
CNF="/usr/share/ssl-cert/ssleay.cnf"

sed -e s#@HostName@#"$NAME"# $CNF > $TMP
echo "subjectAltName=DNS:$NAME" >> $TMP

if ! sudo openssl req -config $TMP -new -x509 -days 3650 -nodes -sha256 \
  -out $CRT -keyout $CRT > $OUT 2>&1
then
  echo Error: Could not create certificate. Openssl output was: >&2
  cat $OUT >&2
  exit 1
fi
sudo chmod 0600 $CRT

TMP=`mktemp`

TPL=`cat /etc/ensite/vhost.conf.template`
TPL=${TPL//\$NAME/$NAME}
TPL=${TPL//\$SITES/$SITES}

echo "$TPL" > $TMP
chmod 0644 $TMP
sudo mv $TMP /etc/apache2/sites-available/$NAME.conf

sudo mono /usr/local/exe/hostscmd/hosts.exe add $NAME >/dev/null
sudo a2ensite -q $NAME
sudo systemctl reload apache2
