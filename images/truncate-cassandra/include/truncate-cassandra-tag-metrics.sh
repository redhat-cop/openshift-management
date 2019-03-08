#!/bin/bash

set -e

if [[ -z "$METRICS_NAMESPACE" ]]; then
   echo "METRICS_NAMESPACE variable not defined"
   exit 1;
fi

echo "Scalling down Heapster and Hawkular pods"
oc -n ${METRICS_NAMESPACE} scale rc heapster --replicas=0
oc -n ${METRICS_NAMESPACE} scale rc hawkular-metrics --replicas=0
export CASSANDRA_POD=$(oc -n ${METRICS_NAMESPACE} get pods | grep ${CASSANDRA_CONTAINER_PREFIX} | head -n 1 | awk '{ print $1 }' )
echo "Cassandra pod is ${CASSANDRA_POD}. Truncating tables"
oc -n ${METRICS_NAMESPACE} exec ${CASSANDRA_POD} -- cqlsh --ssl -e "truncate table hawkular_metrics.metrics_tags_idx"
oc -n ${METRICS_NAMESPACE} exec ${CASSANDRA_POD} -- cqlsh --ssl -e "truncate table hawkular_metrics.metrics_idx"
echo "Scalling up Hawkular and Heapster pods"
oc -n ${METRICS_NAMESPACE} scale rc hawkular-metrics --replicas=1
oc -n ${METRICS_NAMESPACE} scale rc heapster --replicas=1

