#!/bin/bash

TARGET=${TARGET:-notebook}

. init_jupyter_env.sh $TARGET

cd $HOME

OPTIONS=""
if [ $UID -eq 0 ]; then
	OPTIONS="--allow-root"
fi

jupyter-${TARGET} $OPTIONS --NotebookApp.token='' --NotebookApp.password='' --ip 0.0.0.0 --port 8888
