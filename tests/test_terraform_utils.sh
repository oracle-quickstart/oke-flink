## Copyright © 2022-2023, Oracle and/or its affiliates. 
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

#!/bin/bash

DIRNAME=$(pwd)

function render_tfvars {
    cp $1 ${DIRNAME}/test.tfvars
    sed "s|ocid1\.tenancy\.oc1\.\.|${TENANCY_OCID}|g" ${DIRNAME}/test.tfvars > ${DIRNAME}/test.tfvars.tmp && mv ${DIRNAME}/test.tfvars.tmp ${DIRNAME}/test.tfvars
    sed "s|ocid1\.compartment\.oc1\.\.|${COMPARTMENT_OCID}|g" ${DIRNAME}/test.tfvars > ${DIRNAME}/test.tfvars.tmp && mv ${DIRNAME}/test.tfvars.tmp ${DIRNAME}/test.tfvars
    sed "s|kubernetes_version=null|kubernetes_version=\"${K8S_VERSION}\"|g" ${DIRNAME}/test.tfvars > ${DIRNAME}/test.tfvars.tmp && mv ${DIRNAME}/test.tfvars.tmp ${DIRNAME}/test.tfvars
    cat ${DIRNAME}/test.tfvars
}

function deploy_stack {
    log INFO "Deploying stack..."
    terraform apply -var-file="test.tfvars" -auto-approve
}

function init_stack {
    log INFO "Initializing Terraform..."
    terraform init
}

function destroy_stack {
    log INFO "Destroying stack..."
    terraform destroy -auto-approve -refresh=false -var-file="test.tfvars"
}

function get_cluster_access {
    CMD=$(terraform output access_command | tr -d '"')
    eval $CMD
}

