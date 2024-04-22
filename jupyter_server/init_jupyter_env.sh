#!/bin/bash

UNAME=`id -un`
GNAME=`id -gn`
TARGET=$1

if [ $UID -eq 0 ]; then
	HOMEDIR=/root
else
	HOMEDIR=/home/$UNAME
	if [ ! -d $HOMEDIR ]; then
		mkdir $HOMEDIR
	fi
fi

CONFIG_DIR=${HOMEDIR}/.jupyter

mkdir ${HOMEDIR}/.jupyter
cp /opt/jupyter/jupyter_${TARGET}_config.py $CONFIG_DIR
python3 /opt/jupyter/set_jupyter_password.py $CONFIG_DIR/jupyter_${TARGET}_config.json

export HOME=$HOMEDIR
