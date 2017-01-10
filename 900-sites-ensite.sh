#!/bin/bash

NAME=$1
SITES="$HOME/sites"

if [ ! -d $SITES/$NAME/web ]
then
  echo "Error: Directory $SITES/$NAME/web does not exist."
  exit 1
fi

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
