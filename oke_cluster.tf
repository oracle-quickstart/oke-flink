locals {
  kubernetes_version = var.kubernetes_version != "" ? var.kubernetes_version : reverse(data.oci_containerengine_cluster_option.cluster_options.kubernetes_versions)[0]
}

resource "oci_containerengine_cluster" "oci_oke_cluster" {
  depends_on = [oci_identity_policy.oke_key_access_policy]

  compartment_id = var.cluster_compartment_id
  # default to latest version if kubernetes_version is null
  kubernetes_version = local.kubernetes_version
  name               = "${var.cluster_name}-${random_string.deploy_id.result}"
  vcn_id             = var.use_existing_vcn ? var.vcn_id : oci_core_vcn.oke_vcn[0].id

  endpoint_config {
    is_public_ip_enabled = var.is_endpoint_public
    subnet_id            = var.use_existing_vcn ? var.kubernetes_endpoint_subnet : oci_core_subnet.oke_api_endpoint_subnet[0].id
  }

  image_policy_config {
    is_policy_enabled = var.enable_image_validation
    dynamic "key_details" {
      for_each = var.enable_image_validation ? [1] : []
      content {
        kms_key_id = var.image_validation_key_id
      }
    }
  }

  kms_key_id = var.enable_secret_encryption ? var.secrets_key_id : null

  options {
    # service_lb_subnet_ids = var.use_existing_vcn ? [for k, v in zipmap([var.public_lb_subnet, var.private_lb_subnet], [var.allow_deploy_public_lb, var.allow_deploy_private_lb]) : k if v] : [for k, v in zipmap([oci_core_subnet.oke_public_lb_subnet[0].id, oci_core_subnet.oke_private_lb_subnet[0].id], [var.allow_deploy_public_lb, var.allow_deploy_private_lb]) : k if v]
    service_lb_subnet_ids = var.allow_deploy_public_lb ? (var.use_existing_vcn ? [var.public_lb_subnet] : [oci_core_subnet.oke_public_lb_subnet[0].id]) : []

    add_ons {
      is_kubernetes_dashboard_enabled = var.cluster_options_add_ons_is_kubernetes_dashboard_enabled
      is_tiller_enabled               = var.cluster_options_add_ons_is_tiller_enabled
    }

    admission_controller_options {
      is_pod_security_policy_enabled = var.enable_pod_admission_controller
    }

    kubernetes_network_config {
      pods_cidr     = var.pods_cidr
      services_cidr = var.services_cidr
    }

    persistent_volume_config {
      defined_tags = var.cluster_tags
    }
    service_lb_config {
      defined_tags = var.cluster_tags
    }

  }
  defined_tags = var.cluster_tags
}
