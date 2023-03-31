region       = "us-sanjose-1"
tenancy_ocid = "ocid1.tenancy.oc1.."

## Compartments
vcn_compartment_id     = "ocid1.compartment.oc1.."
cluster_compartment_id = "ocid1.compartment.oc1.."

## Network
use_existing_vcn = false
vcn_cidr         = "10.0.0.0/16"

## Endpoint
is_endpoint_public = true

## Cluster
cluster_name = "Flink Cluster"
kubernetes_version=null
ssh_public_key  = ""
node_pool_count = 1
# add_cluster_tag=
# cluster_tag=
# pods_cidr="10.1.0.0/16"
# services_cidr="10.2.0.0/16"
# np1_subnet=
np1_node_count = 1
np1_node_shape = "VM.Standard.E3.Flex"
np1_image_id   = "ocid1.image.oc1.us-sanjose-1.aaaaaaaaysxt7adhnhzammcd7qmk423vtrl562lzufquxedyjqp63u4meg7a"
# np1_add_tag=
# np1_tag=
np1_ocpus                = 2
np1_memory_gb            = 8
np1_enable_autoscaler    = true
np1_autoscaler_min_nodes = 1
np1_autoscaler_max_nodes = 3
# np2_subnet=
np2_create_new_subnet = true
np2_node_count        = 0
np2_node_shape        = ""
np2_image_id          = "ocid1.image.oc1.us-sanjose-1.aaaaaaaanoevcbgqidanfngql2judmt35azqzlwjkq7oqnvjp6qujyrvqqia"
np2_ha                = true
# np2_availability_domain="UWQV:US-ASHBURN-AD-2"
# np2_ocpus     = 4
# np2_memory_gb = 32
np2_enable_autoscaler    = true
np2_autoscaler_min_nodes = 0
np2_autoscaler_max_nodes = 3
# np2_add_tag=
# np2_tag=
# np3_subnet=
np3_create_new_subnet = true
# np3_node_count=
# np3_node_shape=
# np3_ocpus     = 4
# np3_memory_gb = 32
# np3_enable_autoscaler=true
# np3_autoscaler_min_nodes=0
# np3_autoscaler_max_nodes=3
# np3_image_id=
# np3_add_tag=
# np3_tag=
# allow_deploy_private_lb = false
# private_lb_subnet=
allow_deploy_public_lb = true
# public_lb_subnet=

enable_secret_encryption = false
secrets_key_id           = null 

enable_image_validation = false
image_validation_key_id = null 
# enable_pod_admission_controller=

enable_cert_manager   = true
enable_flink          = true
enable_metrics_server = true
enable_monitoring_stack = true

cluster_autoscaler_max_node_provision_time=25
cluster_autoscaler_scale_down_delay_after_add=1 
cluster_autoscaler_scale_down_unneeded_time=1
cluster_autoscaler_unremovable_node_recheck_timeout=1