#!/bin/sh

# args <available space on disk MB> <size of existing postgresql dir MB> <leeway MB> <min storage size MB> <max storage size MB>
# set SELECTED_STORAGE_SIZE_MB
select_store_size()
{
  _AVAIL_SPACE_MB=$1
  _PGSQL_SIZE_MB=$2
  _LEEWAY_MB=$3
  _MIN_SIZE_MB=$4
  _MAX_SIZE_MB=$5
  unset SELECTED_STORAGE_SIZE_MB
  if [ -z "$_AVAIL_SPACE_MB" ] || [ -z "$_PGSQL_SIZE_MB" ] || [ -z "$_LEEWAY_MB" ] || [ -z "$_MIN_SIZE_MB" ] || [ -z "$_MAX_SIZE_MB" ]; then
    echo "Internal error, not enough arguments passed to select_store_size"
  fi

  _USABLE_SPACE_MB=$(( _AVAIL_SPACE_MB + _PGSQL_SIZE_MB ))

  # Give all the available space to the DB, minus what is already used and 3GB for logs etc
  _TARGET_MB=$(( _USABLE_SPACE_MB - _LEEWAY_MB))

  if [ $_TARGET_MB -lt $_MIN_SIZE_MB ]; then
      echo "Flooring storage retention to ${_MIN_SIZE_MB}MB"
      SELECTED_STORAGE_SIZE_MB=$_MIN_SIZE_MB
  elif [ $_TARGET_MB -gt $_MAX_SIZE_MB ]; then
      echo "Capping storage retention to ${_MAX_SIZE_MB}MB"
      SELECTED_STORAGE_SIZE_MB=$_MAX_SIZE_MB
  else
      echo "Storage retention set to ${_TARGET_MB}"
      SELECTED_STORAGE_SIZE_MB=$_TARGET_MB
  fi
}

if [ "$1" = "test" ]; then
  echo "Running tests"
  i=0
  #                                                avail pgdir leew min  max
  echo "test $i"; i=$(( i + 1)); select_store_size 10000 0     1000 1000 20000; [ "$SELECTED_STORAGE_SIZE_MB" -eq 9000 ]  || echo "fail: $SELECTED_STORAGE_SIZE_MB"
  echo "test $i"; i=$(( i + 1)); select_store_size 5000  5000  1000 1000 20000; [ "$SELECTED_STORAGE_SIZE_MB" -eq 9000 ]  || echo "fail: $SELECTED_STORAGE_SIZE_MB"
  echo "test $i"; i=$(( i + 1)); select_store_size 30000 10000 1000 1000 20000; [ "$SELECTED_STORAGE_SIZE_MB" -eq 20000 ] || echo "fail: $SELECTED_STORAGE_SIZE_MB"
  echo "test $i"; i=$(( i + 1)); select_store_size 30000 0     1000 1000 20000; [ "$SELECTED_STORAGE_SIZE_MB" -eq 20000 ] || echo "fail: $SELECTED_STORAGE_SIZE_MB"
  echo "test $i"; i=$(( i + 1)); select_store_size 1000  2000  1000 1000 20000; [ "$SELECTED_STORAGE_SIZE_MB" -eq 2000 ]  || echo "fail: $SELECTED_STORAGE_SIZE_MB"
  echo "test $i"; i=$(( i + 1)); select_store_size 1000  0     1000 1000 20000; [ "$SELECTED_STORAGE_SIZE_MB" -eq 1000 ]  || echo "fail: $SELECTED_STORAGE_SIZE_MB"
  echo "test $i"; i=$(( i + 1)); select_store_size 500   0     1000 1000 20000; [ "$SELECTED_STORAGE_SIZE_MB" -eq 1000 ]  || echo "fail: $SELECTED_STORAGE_SIZE_MB"
  exit 0
fi

# Check we are in right folder
if ! [ -f "./run_node.sh" ]; then
  echo "This script must be run from inside the 'nwaku-compose' folder"
  exit 1
fi

# check if STORAGE_SIZE is already specified
if [ -f "./.env" ]; then
    . ./.env
    if [ -n "$STORAGE_SIZE" ]; then
        echo "STORAGE_SIZE is specified in .env file, doing nothing"
        exit 0
    fi
fi

SUDO=""
PGSQL_SIZE_MB=0
if [ -d "./postgresql" ]; then
    # Check if we need to use SUDO moving forward
    if [ "$(ls postgresql/* 2>&1 | grep -c "Permission denied")" ]; then
        SUDO="sudo"
    fi

    PGSQL_SIZE_MB=$($SUDO du -sBM "./postgresql" | awk '{ print $1 }' | sed 's/^\([0-9]\+\)M$/\1/')
fi

AVAIL_SPACE_MB=$(df -BM . | tail -1 | awk '{ print $4 }' | sed 's/^\([0-9]\+\)M$/\1/')

select_store_size $AVAIL_SPACE_MB $PGSQL_SIZE_MB 1024 1024 $(( 30 * 1024 ))

if [ -z "$SELECTED_STORAGE_SIZE_MB" ]; then
  echo "Failed to selected a storage size"
  exit 1
fi

echo "export STORAGE_SIZE=${SELECTED_STORAGE_SIZE_MB}MB" >> .env
