#!/bin/bash

# Date: 04/18/2017
#
# Script Purpose: Returns the current etcd leader or health of the cluster.
# Version       : 1.0
#

#===============================================================================
#This script must be executed on cluster master node.
#===============================================================================

if [ "$#" -ne 1 ]; then

  echo "
Missing input parameter.

Required health or leader

Example:  ./ocp-etcd.sh health
Example:  ./ocp-etcd.sh leader

"
  exit 1

fi

command_arg=$1

#Variable not constant
masters_list=""

# Check if executed as root
if [[ $EUID -ne 0 ]]; then
  echo "ERROR: This script must be run as root. Aborting."
  exit 1
fi

# Check if executed on OSE master
if ! systemctl status atomic-openshift-master-api >/dev/null 2>&1; then
  echo "ERROR: This script must be run on an OpenShift master. Aborting."
  exit 1
fi

login_result=`oc login -u system:admin`
if [[ "$login_result" == *"Login failed"* ]]; then
  echo "==================================
Login failed!
=================================="
  exit 1
fi

#Check the passed in token and validate.  If failure occurs, stop.
whoami=`oc whoami`
if [[ "$whoami" != "system:admin" ]]; then
  echo "==================================
Script failed user validation!
=================================="
  exit 1
fi

#Check for the masters
#TODO improve this as it might pickup a node thats marked as unscheduled
masters_array=`oc get nodes | grep "SchedulingDisabled" | awk '{print $1}'`
#echo "masters list: $masters_array"
#Check to see that we got a response, if not just die.
if [ -z "$masters_array" ]; then

  echo "=====================================================================
No masters found!  This should not happen, so something bad occured.
====================================================================="
  exit 1

fi

#Process the list of masters
readarray -t masters <<<"$masters_array"
for master in "${masters[@]}"
do
  masters_list+="https://${master}:2379,"
done

masters_list=`echo ${masters_list%?}`

if [ "$command_arg" == "health" ]; then
  #to get a list of etcd members, change cluster-health to member list
  etc_health_string=`etcdctl --endpoints ${masters_list} \
  --ca-file=/etc/origin/master/master.etcd-ca.crt \
  --cert-file=/etc/origin/master/master.etcd-client.crt \
  --key-file=/etc/origin/master/master.etcd-client.key \
  cluster-health`

  status=`echo $etc_health_string | grep "cluster is healthy"`

  #If the var is null, then the cluster is not healthy
  if [ -z "$status" ]; then

    echo "etcd cluster is not healthy"
    exit 1

  else

    echo "etcd cluster is healthy"
    exit 0

  fi
fi

if [ "$command_arg" == "leader" ]; then

  etcd_string=`etcdctl --endpoints ${masters_list} \
  --ca-file=/etc/origin/master/master.etcd-ca.crt \
  --cert-file=/etc/origin/master/master.etcd-client.crt \
  --key-file=/etc/origin/master/master.etcd-client.key \
  member list`

  #Process the list of etcd hosts
  readarray -t leaders <<<"$etcd_string"
  for leader in "${leaders[@]}"
  do
    #echo "leader string: $leader"
    leader=`echo $leader | grep "isLeader=true" | awk '{print $2}' | awk -F= -v key="name" '$1==key {print $2}'`

    if [ -n "$leader" ]; then
      echo "Found etcd leader: $leader"
      exit 0
    fi

  done

  echo "Can't find the etcd leader."
  exit 1
fi

echo "Unknown command: $command_arg"
exit 1
