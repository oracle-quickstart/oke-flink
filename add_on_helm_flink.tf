## Copyright © 2022-2023, Oracle and/or its affiliates. 
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

resource "helm_release" "flink_operator" {
  count            = var.enable_flink ? 1 : 0
  name             = "flink-operator"
  repository       = "https://downloads.apache.org/flink/flink-kubernetes-operator-1.6.1/"
  chart            = "flink-kubernetes-operator"
  namespace        = "flink"
  create_namespace = true
  wait             = true

  depends_on = [
    data.oci_containerengine_cluster_kube_config.oke,
    oci_containerengine_cluster.oci_oke_cluster,
    oci_containerengine_node_pool.oci_oke_node_pool,
    helm_release.cert_manager
  ]
}
