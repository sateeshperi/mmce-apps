#!/bin/bash

LOG_FILE=$FLOAT_LOG_PATH/output
touch $LOG_FILE
exec >$LOG_FILE 2>&1

python3 set_jupyter_password.py

jupyter-lab --allow-root
