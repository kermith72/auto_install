#!/bin/bash
# functions.sh
# version 1.00
# 09/04/2019

exist_object () {
  $CLAPI -o ${1} -a SHOW -v "${2}" | grep "${2};" > /dev/null
}

check_credential () {
  $CLAPI -a POLLERLIST > /dev/null
  if [ $? -ne 0 ]
  then
    echo "Invalid credential !!!!!"
    exit 0
  fi
}
