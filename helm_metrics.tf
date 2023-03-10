## Copyright © 2022, Oracle and/or its affiliates. 
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

locals {
  enable_metrics_server = var.np1_enable_autoscaler || var.np2_enable_autoscaler || var.np3_enable_autoscaler ? true : var.enable_metrics_server
}

# resource "helm_release" "metrics_server" {
#   count      = local.enable_metrics_server ? 1 : 0
#   name       = "metrics-server"
#   repository = "https://kubernetes-sigs.github.io/metrics-server/"
#   chart      = "metrics-server"
#   namespace  = "kube-system"
#   version    = "3.8.2"
#   wait       = false

#   set {
#     name  = "replicas"
#     value = "3"
#   }
#   depends_on = [oci_containerengine_cluster.oci_oke_cluster]
# }

resource "null_resource" "metrics_server" {
  count = local.enable_metrics_server ? 1 : 0

  provisioner "local-exec" {
    command = "mkdir -p ~/.kube/ && oci ce cluster create-kubeconfig --cluster-id $CLUSTER_ID --file ~/.kube/config --region us-sanjose-1 --token-version 2.0.0  --kube-endpoint $ENDPOINT_TYPE"

    environment = {
      CLUSTER_ID    = oci_containerengine_cluster.oci_oke_cluster.id
      ENDPOINT_TYPE = var.is_endpoint_public ? "PUBLIC_ENDPOINT" : "PRIVATE_ENDPOINT"
    }
  }

  provisioner "local-exec" {
    command = "helm repo add metrics-server https://kubernetes-sigs.github.io/metrics-server/"
  }

  provisioner "local-exec" {
    command = "helm upgrade --install metrics-server metrics-server/metrics-server -n kube-system --set replicas=3 --set podDisruptionBudget.enabled=true --set podDisruptionBudget.minAvailable=1 "
  }

  provisioner "local-exec" {
    when       = destroy
    command    = "helm uninstall metrics-server -n kube-system"
    on_failure = continue
  }

  depends_on = [oci_containerengine_node_pool.oci_oke_node_pool]
}

