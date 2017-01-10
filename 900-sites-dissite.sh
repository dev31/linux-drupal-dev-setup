#!/bin/bash

NAME=$1

sudo mono /usr/local/exe/hostscmd/hosts.exe rem $NAME >/dev/null
sudo a2dissite -q $NAME
sudo systemctl reload apache2
