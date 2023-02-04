## Copyright © 2022, Oracle and/or its affiliates. 
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

resource "helm_release" "flink_operator" {
  count            = var.enable_flink ? 1 : 0
  name             = "flink-operator"
  repository       = "https://downloads.apache.org/flink/flink-kubernetes-operator-1.3.1/"
  chart            = "flink-kubernetes-operator"
  namespace        = "flink"
  create_namespace = true
  wait             = true

  depends_on = [
    oci_containerengine_cluster.oci_oke_cluster,
    helm_release.cert_manager
  ]
}
