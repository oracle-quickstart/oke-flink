## Copyright © 2022, Oracle and/or its affiliates. 
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

variable "region" {}

variable "tenancy_ocid" {}

variable "use_existing_vcn" {
  default = false
}

variable "vcn_compartment_id" {}

variable "vcn_cidr" {
  default = "10.0.0.0/16"
}

variable "vcn_id" {
  default = null
}

variable "vcn_tags" {
  default = null
}

variable "is_endpoint_public" {
  default = false
}

variable "kubernetes_endpoint_subnet" {
  default = null
}

variable "cluster_compartment_id" {}

variable "cluster_name" {
  default = "Flink Cluster"
}

variable "kubernetes_version" {
  default = ""
  # default to latest version if null
}

variable "node_pool_count" {
  default = 1
}

variable "cluster_tags" {
  default = null
}

variable "pods_cidr" {
  default = "10.1.0.0/16"
}

variable "services_cidr" {
  default = "10.2.0.0/16"
}

variable "np1_subnet" {
  default = null
}

variable "np1_ha" {
  default = true
}

variable "np1_availability_domain" {
  default = null
}

variable "np1_node_count" {
  default = 3
}

variable "np1_enable_autoscaler" {
  default = true
}

variable "np1_autoscaler_min_nodes" {
  default = 1
}

variable "np1_autoscaler_max_nodes" {
  default = 6
}

variable "np1_node_shape" {
  default = "VM.Standard.E3.Flex"
}

variable "np1_ocpus" {
  default = 4
}

variable "np1_memory_gb" {
  default = 64
}

variable "np1_image_id" {
  default = ""
}

variable "np1_boot_volume_size_in_gbs" {
  default = 50
}

variable "np1_tags" {
  default = null
}

variable "np2_subnet" {
  default = null
}

variable "np2_ha" {
  default = true
}

variable "np2_availability_domain" {
  default = null
}

variable "np2_create_new_subnet" {
  default = false
}

variable "np2_node_count" {
  default = 0
}

variable "np2_enable_autoscaler" {
  default = true
}

variable "np2_autoscaler_min_nodes" {
  default = 0
}

variable "np2_autoscaler_max_nodes" {
  default = 6
}

variable "np2_node_shape" {
  default = null
}

variable "np2_ocpus" {
  default = 4
}

variable "np2_memory_gb" {
  default = 64
}

variable "np2_image_id" {
  default = null
}

variable "np2_boot_volume_size_in_gbs" {
  default = 50
}

variable "np2_tags" {
  default = null
}

variable "np3_subnet" {
  default = null
}

variable "np3_ha" {
  default = true
}

variable "np3_availability_domain" {
  default = null
}

variable "np3_create_new_subnet" {
  default = false
}

variable "np3_node_count" {
  default = 0
}

variable "np3_enable_autoscaler" {
  default = true
}

variable "np3_autoscaler_min_nodes" {
  default = 0
}

variable "np3_autoscaler_max_nodes" {
  default = 6
}

variable "np3_node_shape" {
  default = null
}

variable "np3_ocpus" {
  default = 4
}

variable "np3_memory_gb" {
  default = 64
}

variable "np3_image_id" {
  default = null
}

variable "np3_boot_volume_size_in_gbs" {
  default = 50
}

variable "np3_tags" {
  default = null
}

variable "allow_deploy_public_lb" {
  default = true
}

variable "public_lb_subnet" {
  default = null
}

variable "enable_secret_encryption" {
  default = false
}

variable "secrets_key_id" {
  default = null
}

variable "enable_image_validation" {
  default = false
}

variable "image_validation_key_id" {
  default = null
}

variable "enable_pod_admission_controller" {
  default = null
}

variable "cluster_options_add_ons_is_kubernetes_dashboard_enabled" {
  default = true
}

variable "cluster_options_add_ons_is_tiller_enabled" {
  default = true
}

variable "ssh_public_key" {
  default = null
}

variable "enable_metrics_server" {
  default = true
}

variable "enable_cert_manager" {
  default = true
}

variable "enable_flink" {
  default = true
}


variable "enable_monitoring_stack" {
  default = true
}