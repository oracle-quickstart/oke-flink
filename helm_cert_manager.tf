## https://github.com/jetstack/cert-manager/blob/master/README.md
## https://artifacthub.io/packages/helm/cert-manager/cert-manager

locals {
  enable_cert_manager = var.enable_flink ? true : var.enable_cert_manager
}

resource "helm_release" "cert_manager" {
  count            = local.enable_cert_manager ? 1 : 0
  name             = "cert-manager"
  repository       = "https://charts.jetstack.io"
  chart            = "cert-manager"
  version          = "1.8.2"
  namespace        = "cert-manager"
  create_namespace = true
  wait             = true # wait to allow the webhook be properly configured

  set {
    name  = "installCRDs"
    value = true
  }

  set {
    name  = "webhook.timeoutSeconds"
    value = "30"
  }
  depends_on = [oci_containerengine_cluster.oci_oke_cluster]
}