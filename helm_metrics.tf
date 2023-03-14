## Copyright © 2022-2023, Oracle and/or its affiliates. 
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

locals {
  enable_metrics_server = var.np1_enable_autoscaler || var.np2_enable_autoscaler || var.np3_enable_autoscaler ? true : var.enable_metrics_server
}

resource "helm_release" "metrics_server" {
  count      = local.enable_metrics_server ? 1 : 0
  name       = "metrics-server"
  repository = "https://kubernetes-sigs.github.io/metrics-server/"
  chart      = "metrics-server"
  namespace  = "kube-system"
  version    = "3.8.2"
  wait       = false

  set {
    name  = "replicas"
    value = "3"
  }
  depends_on = [
    data.oci_containerengine_cluster_kube_config.oke,
    oci_containerengine_cluster.oci_oke_cluster
  ]
}
