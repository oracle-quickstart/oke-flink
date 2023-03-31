#!/bin/bash

function render_tfvars {
    K8S_VERSION=${K8S_VERSION:-\"\"}
    cp $1 test.tfvars
    sed -i "" "s|ocid1\.tenancy\.oc1\.\.|${TENANCY_OCID}|g" test.tfvars
    sed -i "" "s|ocid1\.compartment\.oc1\.\.|${COMPARTMENT_OCID}|g" test.tfvars
    sed -i "" "s|kubernetes_version=null|kubernetes_version=\"${K8S_VERSION}\"|g" test.tfvars
}

function deploy_stack {
    log INFO "Deploying stack..."
    terraform apply -var-file="test.tfvars" -auto-approve
}

function destroy_stack {
    log INFO "Destroying stack..."
    terraform destroy -auto-approve -refresh=false
}

function get_cluster_access {
    CMD=$(terraform output access_command | tr -d '"')
    eval $CMD
}

