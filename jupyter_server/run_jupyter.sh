#!/bin/bash

TARGET=${TARGET:-lab}

. init_jupyter_env.sh $TARGET

cd $HOME

OPTIONS=""
if [ $UID -eq 0 ]; then
	OPTIONS="--allow-root"
fi

jupyter-${TARGET} $OPTIONS
