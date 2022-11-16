
# # validate shape and image are compatible

# # data oci_core_image_shapes np1_shape {
# #     image_id = var.np1_image_id
# # }

# # data oci_core_image_shapes np2_shape {
# #     image_id = var.np2_image_id
# # }

# # data oci_core_image_shapes np3_shape {
# #     image_id = var.np3_image_id
# # }

# # locals {
# #     np1_shape_is_compatible = var.np1_node_shape ? contains(data.oci_core_image_shapes.np1_shape, var.np1_node_shape) : true
# #     np2_shape_is_compatible = var.np2_node_shape ? contains(data.oci_core_image_shapes.np2_shape, var.np2_node_shape) : true
# #     np3_shape_is_compatible = var.np3_node_shape ? contains(data.oci_core_image_shapes.np3_shape, var.np3_node_shape) : true
# # }

# # resource null_resource errors {
# #     provisioner local-exec {
# #         command = templatefile("validations.sh", {

# #         })
# #     }
# # }

# # Validate key type for secrets (AES)
# # validate key exists for signature (RSA or ECDSA)


# data "oci_core_subnet" "validate_private_lb_subnet" {
#   count     = var.use_existing_vcn && var.allow_deploy_private_lb && var.allow_deploy_public_lb ? 1 : 0
#   subnet_id = var.private_lb_subnet
# }

# data "oci_core_subnet" "validate_public_lb_subnet" {
#   count     = var.use_existing_vcn && var.allow_deploy_private_lb && var.allow_deploy_public_lb ? 1 : 0
#   subnet_id = var.public_lb_subnet
# }

# locals {
#   # validate multiple LB subnets are AD specific
#   multi_lb_subnets_are_ad_specific = var.use_existing_vcn && var.allow_deploy_private_lb && var.allow_deploy_public_lb ? data.oci_core_subnet.validate_private_lb_subnet[0].availability_domain != null && data.oci_core_subnet.validate_public_lb_subnet[0].availability_domain != null : null
#   # validate k8s version for image signing 
#   # k8s_version_valid = (var.kubernetes_version != null && var.enable_image_validation) && var.kubernetes_version >= "v1.13.0"
# }