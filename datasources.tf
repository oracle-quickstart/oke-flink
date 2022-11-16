## Copyright © 2022, Oracle and/or its affiliates. 
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

data "oci_containerengine_cluster_option" "cluster_options" {
  cluster_option_id = "all"
}

data "oci_containerengine_node_pool_option" "oci_oke_node_pool_option" {
  node_pool_option_id = "all"
}

# Gets home and current regions
data "oci_identity_tenancy" "tenant_details" {
  tenancy_id = var.tenancy_ocid

  provider = oci.current_region
}

data "oci_identity_regions" "home_region" {
  filter {
    name   = "key"
    values = [data.oci_identity_tenancy.tenant_details.home_region_key]
  }

  provider = oci.current_region
}

# Gets kubeconfig
data "oci_containerengine_cluster_kube_config" "oke" {
  cluster_id = oci_containerengine_cluster.oci_oke_cluster.id
}

data "oci_core_services" "all_oci_services" {
  count = var.use_existing_vcn ? 0 : 1
  filter {
    name   = "name"
    values = ["All .* Services In Oracle Services Network"]
    regex  = true
  }
}

data "oci_identity_availability_domains" "ADs" {
  compartment_id = var.tenancy_ocid
}

# data "oci_containerengine_cluster_kube_config" "KubeConfig" {
#   cluster_id    = oci_containerengine_cluster.oci_oke_cluster.id
#   token_version = var.cluster_kube_config_token_version
# }


# locals {
#   gpu = {
#     sources = [for s in data.oci_containerengine_node_pool_option.oci_oke_node_pool_option.sources : s if length(regexall(".*Gen2-GPU.*", s.source_name)) > 0]
#     shapes = {
#       BM = [for s in data.oci_containerengine_node_pool_option.oci_oke_node_pool_option.shapes : s if length(regexall("BM[.]GPU.*", s)) > 0]
#       VM = [for s in data.oci_containerengine_node_pool_option.oci_oke_node_pool_option.shapes : s if length(regexall("VM[.]GPU.*", s)) > 0]
#     }
#   }
#   arm = {
#     sources = [for s in data.oci_containerengine_node_pool_option.oci_oke_node_pool_option.sources : s if length(regexall(".*aarch64.*", s.source_name)) > 0]
#     shapes = {
#       BM = [for s in data.oci_containerengine_node_pool_option.oci_oke_node_pool_option.shapes : s if length(regexall("BM[.]Standard[.]A1.*", s)) > 0]
#       VM = [for s in data.oci_containerengine_node_pool_option.oci_oke_node_pool_option.shapes : s if length(regexall("VM[.]Standard[.]A1.*", s)) > 0]
#     }
#   }
#   x86 = {
#     sources = [for s in data.oci_containerengine_node_pool_option.oci_oke_node_pool_option.sources : s if length(regexall(".*(aarch64|Gen2-GPU).*", s.source_name)) == 0]
#     shapes = {
#       BM = [for s in data.oci_containerengine_node_pool_option.oci_oke_node_pool_option.shapes : s if length(regexall(".*(GPU|A1).*", s)) == 0 && length(regexall("BM.*", s)) > 0]
#       VM = [for s in data.oci_containerengine_node_pool_option.oci_oke_node_pool_option.shapes : s if length(regexall(".*(GPU|A1).*", s)) == 0 && length(regexall("VM.*", s)) > 0]
#     }
#   }
# }

data "oci_limits_limit_definitions" "limit_def" {
  compartment_id = var.tenancy_ocid
  service_name   = "compute"
}

locals {
  availability_map = [for def in data.oci_limits_limit_definitions.limit_def.limit_definitions : def if contains(compact([var.np1_node_shape, var.np2_node_shape, var.np3_node_shape]), def.description)]
  limits_definitions = [
    for ad in range(length(data.oci_identity_availability_domains.ADs.availability_domains)) : [
      for shape in data.oci_core_shapes.valid_shapes[ad].shapes : { "${shape.name}" = { "${data.oci_identity_availability_domains.ADs.availability_domains[ad].name}" = shape.quota_names } }
      if contains(compact([var.np1_node_shape, var.np2_node_shape, var.np3_node_shape]), shape.name)
    ]
  ]
  shape_ad_availability = transpose(
    merge([
      for ad in range(length(data.oci_identity_availability_domains.ADs.availability_domains)) : {
        "${data.oci_identity_availability_domains.ADs.availability_domains[ad].name}" = [
          for shape in data.oci_core_shapes.valid_shapes[ad].shapes : "${shape.name}"
          if contains(compact([var.np1_node_shape, var.np2_node_shape, var.np3_node_shape]), shape.name)
        ]
      }
    ]...)
  )
}

data "oci_core_shapes" "valid_shapes" {
  count               = length(data.oci_identity_availability_domains.ADs.availability_domains)
  compartment_id      = var.cluster_compartment_id
  availability_domain = data.oci_identity_availability_domains.ADs.availability_domains[count.index].name
}

# output valid_shapes {
#   value = data.oci_core_shapes.valid_shapes.*.shapes
# }

# output "shape_ad_availability" {
#   value = local.shape_ad_availability
# }

# output "limits" {
#   value = local.availability_map
# }

# output "limits_definitions" {
#   value = local.limits_definitions
# }

resource "random_string" "deploy_id" {
  length      = 4
  special     = false
  min_numeric = 4
}