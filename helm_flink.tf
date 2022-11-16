resource "helm_release" "flink_operator" {
  count            = var.enable_flink ? 1 : 0
  name             = "flink-operator"
  repository       = "https://downloads.apache.org/flink/flink-kubernetes-operator-1.2.0/"
  chart            = "flink-kubernetes-operator"
  namespace        = "flink"
  create_namespace = true
  wait             = true

  depends_on = [
    oci_containerengine_cluster.oci_oke_cluster,
    helm_release.cert_manager
  ]
}
