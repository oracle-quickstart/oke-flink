# Cluster dynamic group policy needed for nodes to access the encryption key if it was defined
resource "oci_identity_policy" "oke_key_access_policy" {
  count = (var.enable_secret_encryption && var.secrets_key_id != null) || (var.enable_image_validation && var.image_validation_key_id != null) ? 1 : 0
  #Required
  compartment_id = var.tenancy_ocid
  description    = "key access policy for OKE ${random_string.deploy_id.result}"
  name           = "oke_key_access${random_string.deploy_id.result}"
  statements = compact([
    var.enable_secret_encryption && var.secrets_key_id != null ? "Allow any-user to use keys in tenancy where ALL {request.principal.type = 'cluster', target.key.id='${var.secrets_key_id}'}" : "",
    var.enable_image_validation && var.image_validation_key_id != null ? "Allow any-user to use keys in tenancy where ALL {request.principal.type = 'cluster', target.key.id='${var.image_validation_key_id}'}" : ""
  ])
}

resource "oci_identity_policy" "autoscaler_policy" {
  count = (var.np1_enable_autoscaler || var.np2_enable_autoscaler || var.np3_enable_autoscaler) ? 1 : 0
  #Required
  compartment_id = var.cluster_compartment_id
  description    = "Cluster autoscaler policy for OKE ${random_string.deploy_id.result}"
  name           = "cluster_autoscaler_${random_string.deploy_id.result}"
  provider       = oci.home_region
  statements = compact([
    "Allow any-user to manage cluster-node-pools in compartment id ${var.cluster_compartment_id} where ALL {request.principal.type = 'cluster', request.principal.id = ${oci_containerengine_cluster.oci_oke_cluster.id}}",
    "Allow any-user to manage instance-family in compartment id ${var.cluster_compartment_id} where ALL {request.principal.type = 'cluster', request.principal.id = ${oci_containerengine_cluster.oci_oke_cluster.id}}",
    "Allow any-user to use subnets in compartment id ${var.vcn_compartment_id} where ALL {request.principal.type = 'cluster', request.principal.id = ${oci_containerengine_cluster.oci_oke_cluster.id}}",
    "Allow any-user to read virtual-network-family in compartment id ${var.vcn_compartment_id} where ALL {request.principal.type = 'cluster', request.principal.id = ${oci_containerengine_cluster.oci_oke_cluster.id}}",
    "Allow any-user to use vnics in compartment id ${var.vcn_compartment_id} where ALL {request.principal.type = 'cluster', request.principal.id = ${oci_containerengine_cluster.oci_oke_cluster.id}}",
    "Allow any-user to inspect compartments in compartment id ${var.cluster_compartment_id} where ALL {request.principal.type = 'cluster', request.principal.id = ${oci_containerengine_cluster.oci_oke_cluster.id}}",
    "Allow any-user to inspect compartments in compartment id ${var.vcn_compartment_id} where ALL {request.principal.type = 'cluster', request.principal.id = ${oci_containerengine_cluster.oci_oke_cluster.id}}"
  ])
}
