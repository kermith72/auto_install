#!/bin/bash
# functions.sh
# version 1.00
# 09/04/2019
# use debug
# version 1.01
# 12/10/2019

exist_object () {
  $CLAPI -o ${1} -a SHOW -v "${2}" | grep "${2};" > /dev/null
}

exec_clapi () {
  [ $DEBUG == "yes" ] && echo -o  ${1} -a ${2} -v "${3}" 
  $CLAPI -o ${1} -a ${2} -v "${3}" 
}

check_credential () {
  $CLAPI -a POLLERLIST > /dev/null
  if [ $? -ne 0 ]
  then
    echo "Invalid credential !!!!!"
    exit 0
  fi
}
