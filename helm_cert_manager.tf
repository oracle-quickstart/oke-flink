## Copyright © 2022, Oracle and/or its affiliates. 
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

## https://github.com/jetstack/cert-manager/blob/master/README.md
## https://artifacthub.io/packages/helm/cert-manager/cert-manager

locals {
  enable_cert_manager = var.enable_flink ? true : var.enable_cert_manager
}

# resource "helm_release" "cert_manager" {
#   count            = local.enable_cert_manager ? 1 : 0
#   name             = "cert-manager"
#   repository       = "https://charts.jetstack.io"
#   chart            = "cert-manager"
#   version          = "1.8.2"
#   namespace        = "cert-manager"
#   create_namespace = true
#   wait             = true # wait to allow the webhook be properly configured

#   set {
#     name  = "installCRDs"
#     value = true
#   }

#   set {
#     name  = "webhook.timeoutSeconds"
#     value = "30"
#   }
#   depends_on = [oci_containerengine_cluster.oci_oke_cluster]
# }


resource "null_resource" "cert_manager" {
  count = local.enable_cert_manager ? 1 : 0

  provisioner "local-exec" {
    command = "mkdir -p ~/.kube/ && oci ce cluster create-kubeconfig --cluster-id $CLUSTER_ID --file ~/.kube/config --region us-sanjose-1 --token-version 2.0.0  --kube-endpoint $ENDPOINT_TYPE"

    environment = {
      CLUSTER_ID    = oci_containerengine_cluster.oci_oke_cluster.id
      ENDPOINT_TYPE = var.is_endpoint_public ? "PUBLIC_ENDPOINT" : "PRIVATE_ENDPOINT"
    }
  }

  provisioner "local-exec" {
    command = "helm repo add cert-manager https://charts.jetstack.io"
  }


  provisioner "local-exec" {
    command = "kubectl create ns cert-manager"
  }

  provisioner "local-exec" {
    command = "helm install cert-manager cert-manager/cert-manager -n cert-manager --version 1.8.2 --set installCRDs=true --set webhook.timeoutSeconds=30 --wait"
  }

  provisioner "local-exec" {
    when       = destroy
    command    = "helm uninstall cert-manager -n cert-manager"
    on_failure = continue
  }

  provisioner "local-exec" {
    when       = destroy
    command    = "helm repo remove cert-manager"
    on_failure = continue
  }

  provisioner "local-exec" {
    when       = destroy
    command    = "kubectl delete ns cert-manager"
    on_failure = continue
  }

  depends_on = [
    oci_containerengine_cluster.oci_oke_cluster,
    oci_containerengine_node_pool.oci_oke_node_pool
  ]

}
