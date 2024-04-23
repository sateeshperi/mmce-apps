#!/bin/bash

if [[ -z $RSTUDIO_USER ]]; then
    RSTUDIO_USER="rstudio-user"
fi

useradd "$RSTUDIO_USER"
if [[ -z $RSTUDIO_PASS ]]; then
    chpasswd -e <<< "${RSTUDIO_USER}":'$6$rGZq3zj6dqNzh2Ta$HzdyfH2o7kf1ahlwo1JRrxjZ8x2OoeTnLt/XZSYUpxMGdP.mTFZRNepTc9UQ1lNzabDTvf46LUZMviJM528VZ/'
else
    chpasswd <<< "${RSTUDIO_USER}":"${RSTUDIO_PASS}"
fi

rstudio-server start

while true; do
    sleep 3600
done
