## Copyright © 2022, Oracle and/or its affiliates. 
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

resource "tls_private_key" "public_private_key_pair" {
  count     = var.ssh_public_key == null ? 1 : 0
  algorithm = "RSA"
}

locals {
  node_pools = tolist([for node_pool in [
    var.node_pool_count >= 1 ?
    {
      subnet                  = var.use_existing_vcn ? var.np1_subnet : oci_core_subnet.oke_nodepool_subnet[0].id
      ha                      = var.np1_ha
      ad                      = var.np1_availability_domain
      node_count              = var.np1_enable_autoscaler ? var.np1_autoscaler_min_nodes : var.np1_node_count
      node_shape              = var.np1_node_shape
      image_id                = local.np1_oke_image_id
      boot_volume_size_in_gbs = var.np1_boot_volume_size_in_gbs
      tags                    = var.np1_tags
      ocpus                   = var.np1_ocpus
      memory_gb               = var.np1_memory_gb
    } : null,
    var.node_pool_count >= 2 ? {
      subnet                  = var.use_existing_vcn ? var.np2_subnet : var.np2_create_new_subnet ? oci_core_subnet.oke_nodepool_subnet[1].id : oci_core_subnet.oke_nodepool_subnet[0].id
      ha                      = var.np2_ha
      ad                      = var.np2_availability_domain
      node_count              = var.np2_enable_autoscaler ? var.np2_autoscaler_min_nodes : var.np2_node_count
      node_shape              = var.np2_node_shape
      image_id                = local.np2_oke_image_id
      boot_volume_size_in_gbs = var.np2_boot_volume_size_in_gbs
      tags                    = var.np2_tags
      ocpus                   = var.np2_ocpus
      memory_gb               = var.np2_memory_gb
    } : null,
    var.node_pool_count >= 3 ? {
      subnet                  = var.use_existing_vcn ? var.np3_subnet : var.np3_create_new_subnet ? oci_core_subnet.oke_nodepool_subnet[length(oci_core_subnet.oke_nodepool_subnet) - 1].id : oci_core_subnet.oke_nodepool_subnet[0].id
      ha                      = var.np3_ha
      ad                      = var.np3_availability_domain
      node_count              = var.np3_enable_autoscaler ? var.np3_autoscaler_min_nodes : var.np3_node_count
      node_shape              = var.np3_node_shape
      image_id                = local.np3_oke_image_id
      boot_volume_size_in_gbs = var.np3_boot_volume_size_in_gbs
      tags                    = var.np3_tags
      ocpus                   = var.np3_ocpus
      memory_gb               = var.np3_memory_gb
    } : null
  ] : node_pool if node_pool != null])
}

# output "node_pools_definition" {
#   value = local.node_pools
# }

resource "oci_containerengine_node_pool" "oci_oke_node_pool" {
  count = length(local.node_pools)

  cluster_id         = oci_containerengine_cluster.oci_oke_cluster.id
  compartment_id     = var.cluster_compartment_id
  kubernetes_version = var.kubernetes_version != "" ? var.kubernetes_version : reverse(data.oci_containerengine_cluster_option.cluster_options.kubernetes_versions)[0]
  name               = "${local.node_pools[count.index]["node_shape"]}_Node_Pool"
  node_shape         = local.node_pools[count.index]["node_shape"]

  #   initial_node_labels {
  #     key   = var.node_pool_initial_node_labels_key
  #     value = var.node_pool_initial_node_labels_value
  #   }

  node_source_details {
    image_id                = local.node_pools[count.index]["image_id"]
    source_type             = "IMAGE"
    boot_volume_size_in_gbs = local.node_pools[count.index]["boot_volume_size_in_gbs"]
  }

  ssh_public_key = var.ssh_public_key != null ? var.ssh_public_key : tls_private_key.public_private_key_pair[0].public_key_openssh

  node_config_details {
    dynamic "placement_configs" {
      for_each = [for ad in local.node_pools[count.index]["ha"] ? local.shape_ad_availability[local.node_pools[count.index]["node_shape"]] : [local.node_pools[count.index]["ad"]] : ad]
      content {
        subnet_id           = local.node_pools[count.index]["subnet"]
        availability_domain = placement_configs.value
      }
    }
    size         = local.node_pools[count.index]["node_count"]
    defined_tags = local.node_pools[count.index]["tags"]
  }

  dynamic "node_shape_config" {
    for_each = length(regexall("Flex", local.node_pools[count.index]["node_shape"])) > 0 ? [1] : []
    content {
      ocpus         = local.node_pools[count.index]["ocpus"]
      memory_in_gbs = local.node_pools[count.index]["memory_gb"]
    }
  }
  defined_tags = local.node_pools[count.index]["tags"]
}
