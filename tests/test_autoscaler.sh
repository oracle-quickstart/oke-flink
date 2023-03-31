#!/bin/bash
set -e

clean_up () {
    ARG=$?
    log INFO "Cleaning up..."
    kubectl delete deployment nginx
    exit $ARG
} 
trap clean_up EXIT

BASE_DIR=$(dirname "$0")
source "./${BASE_DIR}/test_utils.sh"

CURRENT_NB_NODES=$(kubectl get nodes --no-headers | wc -l | tr -d " ")
EXPECTED_NB_NODES=$(( $CURRENT_NB_NODES + 1 ))

log INFO "Current nb nodes: ${CURRENT_NB_NODES}, Expected nb nodes: ${EXPECTED_NB_NODES}"

log INFO "Deploying nginx..."
retry "kubectl apply -f \"$1\"" || (echo "Could not deploy nginx" && exit 1)

log INFO "Waiting for deployment to be ready..."
retry "kubectl wait --for=condition=Available=True deployment --timeout=5m -l app=nginx" || (log ERROR "Nginx deployment timed out" && exit 1)

log INFO "Scale nginx deployment to prompt a nodepool scale up"
retry "kubectl scale deployment nginx --replicas=$2" || (log ERROR "Failed scaling deployment" && exit 1)

log INFO "Waiting for deployment to be ready..."
retry "kubectl wait --for=condition=Available=True deployment -l app=nginx --timeout=5m" || (log ERROR "Deployment still not ready" && exit 1)

# check the nodepool has increased (it must have or the deployment would not have scaled)
NB_NODES=$(kubectl get nodes --no-headers | wc -l | tr -d " ")

if [[ $NB_NODES -ne $EXPECTED_NB_NODES ]]; then
    log ERROR "Wrong number of node after scaling: $NB_NODES";
    exit 1;
fi

log INFO "Scale nginx back down..."
retry "kubectl scale deployment nginx --replicas=0" || (log ERROR "Failed scaling deployment" && exit 1)

log INFO "Wait for the deployment to be ready..."
retry "kubectl wait --for=condition=Available=True deployment -l app=nginx --timeout=60s" || (log ERROR "Deployment did not scale down in time" && exit 1)

# get the autoscale pod to tail
AUTOSCALER_LEADER=$(kubectl get lease cluster-autoscaler -n kube-system --no-headers | awk -F" " '{print $2}')
log INFO "cluster-autoscaler leader is pod ${AUTOSCALER_LEADER}. Tailing the logs"

# Tail the log until we find the scaling down mention (tail in subshell so the command exits when grep finds the line)
log INFO "Waiting for the nodepool to scale down..."
set +e
(kubectl logs --since=5s ${AUTOSCALER_LEADER} -n kube-system &) | grep -p "Scale-down: removing empty node"

log INFO "Node is being removed..."
(kubectl logs --since=5s ${AUTOSCALER_LEADER} -n kube-system &) | grep -p "Successfully added ignore-taint.cluster-autoscaler.kubernetes.io/oke-impending-node-termination"

(kubectl logs --since=5s ${AUTOSCALER_LEADER} -n kube-system &) | grep -p "1 unregistered nodes present"
log INFO "Waiting for the node to be removed..."
set -e

COUNTER=12
NB_NODES=$(kubectl get nodes --no-headers | grep -p " Ready " | wc -l | tr -d " ")
while [[ $NB_NODES -gt $CURRENT_NB_NODES && $COUNTER -gt 0 ]]; do
    log INFO "Number of nodes is $NB_NODES, expecting $CURRENT_NB_NODES"
    sleep 20
    NB_NODES=$(kubectl get nodes --no-headers | grep -p " Ready " | wc -l | tr -d " ")
    COUNTER=$(( $COUNTER - 1 ))
done

kubectl get nodes
if [[ $NB_NODES -ne $CURRENT_NB_NODES ]]; then
    log ERROR "Nodepool did not scale down in time";
    exit 1
fi
