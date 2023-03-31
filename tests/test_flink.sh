#!/bin/bash
set -e
clean_up () {
    ARG=$?
    log INFO "Cleaning up..."
    log INFO "Tearing the Flink deployment down..."
    retry "kubectl delete flinkdeployment basic-example -n flink"
    exit $ARG
} 
trap clean_up EXIT

BASE_DIR=$(dirname "$0")
source "./${BASE_DIR}/test_utils.sh"

log INFO "Deploying Flink app..."
retry "kubectl apply -f ${BASE_DIR}/../examples/flink-basic-example.yaml"

log INFO "Waiting for the Flink deployment to be ready..."
retry "kubectl wait --for=jsonpath='{.status.jobManagerDeploymentStatus}'=READY flinkdeployment -l app=flink -n flink --timeout=5m" || (log ERROR "Deployment timed out" && exit 1) 

log INFO "Waiting for the Flink job to be running..."
retry "kubectl wait --for=jsonpath='{.status.jobStatus.state}'=RUNNING flinkdeployment -l app=flink -n flink --timeout=5m" || (log ERROR "Job start timed out" && exit 1) 
