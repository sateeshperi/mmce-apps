#!/bin/bash

FLOAT_BIN=float

# MMCE user configuration
MMCE_ADDR_DEFAULT="localhost:443"
MMCE_ADDR=$MMCE_ADDR_DEFAULT
MMCE_USER_DEFAULT="admin"
MMCE_USER=$MMCE_USER_DEFAULT
MMCE_PASSWD_DEFAULT="memverge"
MMCE_PASSWD=$MMCE_PASSWD_DEFAULT

LOG_FILE="stdout"

RSTUDIO_CPU_DEFAULT=2
RSTUDIO_CPU=$RSTUDIO_CPU_DEFAULT
RSTUDIO_MEM_DEFAULT=4
RSTUDIO_MEM=$RSTUDIO_MEM_DEFAULT
RSTUDIO_PORT_DEFAULT=8787
RSTUDIO_PORT=$RSTUDIO_PORT_DEFAULT
RSTUDIO_USER_DEFAULT="rstudio"
RSTUDIO_USER=$RSTUDIO_USER_DEFAULT
RSTUDIO_PASS_DEFAULT="Welcome123!"
RSTUDIO_PASS=$RSTUDIO_PASS_DEFAULT
RSTUDIO_SG=""
RSTUDIO_VOLUMES=""
RSTUDIO_GATEWAY=""

function log() {
  if [ ${LOG_FILE} != "stdout" ]; then
    echo $(date): "$@" >> ${LOG_FILE}
  fi
  echo $(date): "$@"
}

function die() {
  if [ ${LOG_FILE} != "stdout" ]; then
    echo $(date): ERROR: "$@" >> ${LOG_FILE}
  fi
  >&2 echo $(date): ERROR: "$@"
  exit 1
}

function check_jq() {
    which jq > /dev/null 2>&1
    if [ $? -ne 0 ]; then
        die "Command jq not found, please install it before using this script"
    fi
}

function mmce_login() {
    $FLOAT_BIN login -u $MMCE_USER -p $MMCE_PASSWD -a $MMCE_ADDR
    if [ $? -ne 0 ]; then
        die "Login failed"
    fi
}

function mmce_check_login() {
    info=$($FLOAT_BIN login --info -F json 2>/dev/null)
    if [ $? -ne 0 ]; then
        mmce_login
        return
    fi
    username=$(echo $info|jq -r .username)
    address=$(echo $info|jq -r .address)
    if [ $address != "$MMCE_ADDR" ]; then
        die "Current login server mismatch"
    fi
    if [ $username != "$MMCE_USER" ]; then
        die "Current login user mismatch"
    fi
}

function start_rstudio() {
    mmce_check_login
    if [ -z $RSTUDIO_SG ]; then
        SG_OPT=""
    else
        SG_OPT="--securityGroup $RSTUDIO_SG "
    fi
    if [ -z $RSTUDIO_GATEWAY ]; then
        GATEWAY_OPT=""
    else
        GATEWAY_OPT="--gateway $RSTUDIO_GATEWAY --targetPort $RSTUDIO_PORT"
    fi
    echo "$FLOAT_BIN submit -i rstudio --cpu $RSTUDIO_CPU --mem $RSTUDIO_MEM \
-e RSTUDIO_USER=$RSTUDIO_USER -e RSTUDIO_PASS=$RSTUDIO_PASS \
$SG_OPT --publish $RSTUDIO_PORT:8787 $GATEWAY_OPT $RSTUDIO_VOLUMES \
--extraOptions \"--irmap-scan-path /home/${RSTUDIO_USER}/\" -f"
    $FLOAT_BIN submit -i rstudio --cpu $RSTUDIO_CPU --mem $RSTUDIO_MEM \
      -e RSTUDIO_USER=$RSTUDIO_USER -e RSTUDIO_PASS=$RSTUDIO_PASS \
      $SG_OPT --publish $RSTUDIO_PORT:8787 $GATEWAY_OPT $RSTUDIO_VOLUMES \
      --extraOptions "--irmap-scan-path /home/${RSTUDIO_USER}/" -f
    if [ $? -ne 0 ]; then
        die "Submit job failed"
    fi
    exit 0
}

function list_rstudio() {
    mmce_check_login
    $FLOAT_BIN squeue -f image=rstudio
    if [ $? -ne 0 ]; then
        die "Submit job failed"
    fi
    exit 0
}

function stop_rstudio() {
    mmce_check_login
    echo "$FLOAT_BIN cancel -j $RSTUDIO_JOB"
    $FLOAT_BIN cancel -j $RSTUDIO_JOB
    exit 0
}

function migrate_rstudio() {
    mmce_check_login
    echo "$FLOAT_BIN migrate -j $RSTUDIO_JOB -c $RSTUDIO_CPU -m $RSTUDIO_MEM"
    $FLOAT_BIN migrate -j $RSTUDIO_JOB -c $RSTUDIO_CPU -m $RSTUDIO_MEM
    exit 0
}

MY_NAME=$(basename "$0")

function usage() {
    echo "Usage: <parameters> <action>"
    echo "  action=start To start a RStudio server"
    echo "    -c        Number of CPU cores to run RStudio, default: $RSTUDIO_CPU_DEFAULT"
    echo "    -m        Size of memory to run RStudio, default: $RSTUDIO_MEM_DEFAULT"
    echo "    -p        Port of RStudio service, default: $RSTUDIO_PORT_DEFAULT"
    echo "    -s        The Security group which need to be attached for allow RStudio port"
    echo "    -d        Data volumes which need to be attached, default is None"
    echo "    -u        The rstudio login user, default: $RSTUDIO_USER_DEFAULT"
    echo "    -t        The rstudio login password, default: $RSTUDIO_PASS_DEFAULT"
    echo "    -g        The gateway ID this rstudio want to connect to, default: None"
    echo ""
    echo "  action=list To list all RStudio servers"
    echo ""
    echo "  action=stop To stop one RStudio server"
    echo "    -j        The target job ID"
    echo ""
    echo "  action=migrate To migrate a RStudio server"
    echo "    -j        The target job ID"
    echo "    -c        Number of CPU cores to run RStudio"
    echo "    -m        Size of memory to run RStudio"
    echo ""
    echo "Global parameters:"
    echo "    -B        Float command binary path"
    echo "    -A        MMCE service address, default: $MMCE_ADDR_DEFAULT"
    echo "    -U        MMCE username, default: $MMCE_USER_DEFAULT"
    echo "    -P        MMCE password, default: $MMCE_PASSWD_DEFAULT"
    echo "    -L        Logfile, default: stdout"
    echo "    -h        Show this help message"
}
check_jq

CMD_OPTS="B:A:U:P:L:c:m:p:s:d:u:t:j:hg:"

# Read arguments
while getopts $CMD_OPTS OPTION; do
  case "$OPTION" in
  c)
    RSTUDIO_CPU=${OPTARG}
    ;;
  m)
    RSTUDIO_MEM=${OPTARG}
    ;;
  p)
    RSTUDIO_PORT=${OPTARG}
    ;;
  s)
    RSTUDIO_SG=${OPTARG}
    ;;
  d)
    RSTUDIO_VOLUMES="${RSTUDIO_VOLUMES} --dataVolume ${OPTARG}"
    ;;
  u)
    RSTUDIO_USER=${OPTARG}
    ;;
  t)
    RSTUDIO_PASS=${OPTARG}
    ;;
  j)
    RSTUDIO_JOB=${OPTARG}
    ;;
  g)
    RSTUDIO_GATEWAY=${OPTARG}
    ;;
  B)
    FLOAT_BIN=${OPTARG}
    ;;
  A)
    MMCE_ADDR=${OPTARG}
    ;;
  U)
    MMCE_USER=${OPTARG}
    ;;
  P)
    MMCE_PASSWD=${OPTARG}
    ;;
  L)
    LOG_FILE=${OPTARG}
    ;;
  h)
    usage
    exit 0
    ;;
  *)
    usage
    exit 1
  esac
done

shift $((OPTIND -1))

if [ -z $1 ]; then
  echo -e "Please input action:\n"

  usage
  exit 1
fi
ACTION=$1

#check args
if [ $ACTION == "start" ]; then
	start_rstudio
fi
if [ $ACTION == "list" ]; then
	list_rstudio
fi
if [ $ACTION == "stop" ]; then
	stop_rstudio
fi
if [ $ACTION == "migrate" ]; then
	migrate_rstudio
fi
die "Invalid action: $ACTION"
