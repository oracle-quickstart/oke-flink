## Copyright © 2022, Oracle and/or its affiliates. 
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

# Check if there is an OKE image for the image selected
data "oci_core_image" "np1_image" {
  count    = var.node_pool_count >= 1 ? 1 : 0
  image_id = var.np1_image_id
}
data "oci_core_image" "np2_image" {
  count    = var.node_pool_count >= 2 ? 1 : 0
  image_id = var.np2_image_id
}
data "oci_core_image" "np3_image" {
  count    = var.node_pool_count >= 3 ? 1 : 0
  image_id = var.np3_image_id
}

# Identify if an OKE specific image is available for the Compute image selected
locals {
  k8s_version = replace(local.kubernetes_version, "v", "")
  np1_oke_image = var.node_pool_count >= 1 ? [for option
    in data.oci_containerengine_node_pool_option.oci_oke_node_pool_option.sources :
  option if length(regexall("${data.oci_core_image.np1_image[0].display_name}-OKE-${local.k8s_version}", option.source_name)) > 0] : []
  np1_oke_image_id = length(local.np1_oke_image) > 0 ? local.np1_oke_image[0].image_id : var.np1_image_id
  np2_oke_image = var.node_pool_count >= 2 ? [for option
    in data.oci_containerengine_node_pool_option.oci_oke_node_pool_option.sources :
  option if length(regexall("${data.oci_core_image.np2_image[0].display_name}-OKE-${local.k8s_version}", option.source_name)) > 0] : []
  np2_oke_image_id = length(local.np2_oke_image) > 0 ? local.np2_oke_image[0].image_id : var.np2_image_id
  np3_oke_image = var.node_pool_count >= 3 ? [for option
    in data.oci_containerengine_node_pool_option.oci_oke_node_pool_option.sources :
  option if length(regexall("${data.oci_core_image.np3_image[0].display_name}-OKE-${local.k8s_version}", option.source_name)) > 0] : []
  np3_oke_image_id = length(local.np3_oke_image) > 0 ? local.np3_oke_image[0].image_id : var.np3_image_id
}
