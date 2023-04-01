## Copyright © 2022-2023, Oracle and/or its affiliates. 
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

#!/bin/bash

set -e
clean_up () {
    ARG=$?
    log INFO "Cleaning up..."
    destroy_stack || exit 1
    exit $ARG
} 
trap clean_up EXIT

BASE_DIR=$(dirname "$0")
echo "$BASE_DIR"

source ./${BASE_DIR}/test_utils.sh
source ./${BASE_DIR}/test_terraform_utils.sh

render_tfvars "${BASE_DIR}/A1_full_1np.tfvars"

init_stack || exit 1
deploy_stack || exit 1
get_cluster_access || exit 1

# test autoscaler on first node pool (10 1GB mem pods)
set +e
( ./$BASE_DIR/test_autoscaler.sh "./${BASE_DIR}/manifests/autoscaling.yaml" 10 ) || exit 1

( ./$BASE_DIR/test_flink.sh ) || exit 1
set -e

render_tfvars "${BASE_DIR}/A2_full_3np.tfvars"
deploy_stack || exit 1

# test autoscaler on second node pool (large 12G mem pod) to scale from 0 nodes to 1
set +e
( ./$BASE_DIR/test_autoscaler.sh "./${BASE_DIR}/manifests/autoscaling_np2.yaml" 1 ) || exit 1
set -e
exit 0