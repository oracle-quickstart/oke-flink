## Copyright © 2022, Oracle and/or its affiliates. 
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

# resource "helm_release" "flink_operator" {
#   count            = var.enable_flink ? 1 : 0
#   name             = "flink-operator"
#   repository       = "https://downloads.apache.org/flink/flink-kubernetes-operator-1.3.1/"
#   chart            = "flink-kubernetes-operator"
#   namespace        = "flink"
#   create_namespace = true
#   wait             = true

#   depends_on = [
#     oci_containerengine_cluster.oci_oke_cluster,
#     helm_release.cert_manager
#   ]
# }


resource "null_resource" "flink_operator" {
  count = var.enable_flink ? 1 : 0

  provisioner "local-exec" {
    command = "mkdir -p ~/.kube/ && oci ce cluster create-kubeconfig --cluster-id $CLUSTER_ID --file ~/.kube/config --region us-sanjose-1 --token-version 2.0.0  --kube-endpoint $ENDPOINT_TYPE"

    environment = {
      CLUSTER_ID    = oci_containerengine_cluster.oci_oke_cluster.id
      ENDPOINT_TYPE = var.is_endpoint_public ? "PUBLIC_ENDPOINT" : "PRIVATE_ENDPOINT"
    }
  }

  provisioner "local-exec" {
    command = "helm repo add flink-kubernetes-operator https://downloads.apache.org/flink/flink-kubernetes-operator-1.3.1/"
  }

  provisioner "local-exec" {
    command = "kubectl create ns flink"
  }

  provisioner "local-exec" {
    command = "helm install flink-operator flink-kubernetes-operator/flink-kubernetes-operator -n flink --wait"
  }

  provisioner "local-exec" {
    when       = destroy
    command    = "helm uninstall flink-operator -n flink"
    on_failure = continue
  }

  provisioner "local-exec" {
    when       = destroy
    command    = "helm repo remove flink-kubernetes-operator"
    on_failure = continue
  }

  provisioner "local-exec" {
    when       = destroy
    command    = "kubectl delete ns flink"
    on_failure = continue
  }

  depends_on = [
    oci_containerengine_cluster.oci_oke_cluster,
    oci_containerengine_node_pool.oci_oke_node_pool,
    null_resource.cert_manager
  ]

}
