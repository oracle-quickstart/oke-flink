# Copyright (c) 2021, 2023, Oracle and/or its affiliates. All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at http://oss.oracle.com/licenses/upl.
# 

locals {
  cluster_autoscaler_supported_k8s_versions           = { "1.21" = "1.21.1-3", "1.22" = "1.22.2-4", "1.23" = "1.23.0-4", "1.24" = "1.24.0-5", "1.25" = "1.25.0-6" } # There's no API to get that list. Need to be updated manually
  cluster_autoscaler_image_version                    = lookup(local.cluster_autoscaler_supported_k8s_versions, local.k8s_major_minor_version, reverse(values(local.cluster_autoscaler_supported_k8s_versions))[0])
  cluster_autoscaler_image                            = "iad.ocir.io/oracle/oci-cluster-autoscaler:${local.cluster_autoscaler_image_version}"
  cluster_autoscaler_log_level_verbosity              = 4
  cluster_autoscaler_max_node_provision_time          = "25m"
  cluster_autoscaler_scale_down_delay_after_add       = "10m"
  cluster_autoscaler_scale_down_unneeded_time         = "10m"
  cluster_autoscaler_unremovable_node_recheck_timeout = "5m"
  cluster_autoscaler_cloud_provider                   = tonumber(local.k8s_minor_version) <= 23 ? "oci" : "oci-oke"
  cluster_autoscaler_enabled                          = contains(keys(local.cluster_autoscaler_supported_k8s_versions), local.k8s_major_minor_version) ? (var.np1_enable_autoscaler || var.np2_enable_autoscaler || var.np3_enable_autoscaler) : false
  k8s_major_minor_version                             = regex("\\d+(?:\\.(?:\\d+|x)(?:))", local.kubernetes_version)
  k8s_minor_version                                   = regex("^\\d+", replace(local.kubernetes_version, "v1.", ""))
}

resource "kubernetes_service_account" "cluster_autoscaler_sa" {
  count = local.cluster_autoscaler_enabled ? 1 : 0

  metadata {
    name      = "cluster-autoscaler"
    namespace = "kube-system"
    labels = {
      k8s-addon = "cluster-autoscaler.addons.k8s.io"
      k8s-app   = "cluster-autoscaler"
    }
  }
  automount_service_account_token = true # workaround to support ORM deprecated terraform providers

  depends_on = [oci_containerengine_node_pool.oci_oke_node_pool]
}

resource "kubernetes_cluster_role" "cluster_autoscaler_cr" {
  count = local.cluster_autoscaler_enabled ? 1 : 0

  metadata {
    name = "cluster-autoscaler"
    labels = {
      k8s-addon = "cluster-autoscaler.addons.k8s.io"
      k8s-app   = "cluster-autoscaler"
    }
  }

  rule {
    api_groups = [""]
    resources  = ["events", "endpoints"]
    verbs      = ["create", "patch"]
  }
  rule {
    api_groups = [""]
    resources  = ["pods/eviction"]
    verbs      = ["create"]
  }
  rule {
    api_groups = [""]
    resources  = ["pods/status"]
    verbs      = ["update"]
  }
  rule {
    api_groups     = [""]
    resource_names = ["cluster-autoscaler"]
    resources      = ["endpoints"]
    verbs          = ["get", "update"]
  }
  rule {
    api_groups = [""]
    resources  = ["nodes"]
    verbs      = ["watch", "list", "get", "patch", "update"]
  }
  rule {
    api_groups = [""]
    resources  = ["pods", "services", "replicationcontrollers", "persistentvolumeclaims", "persistentvolumes", "namespaces"]
    verbs      = ["watch", "list", "get"]
  }
  rule {
    api_groups = ["extensions"]
    resources  = ["replicasets", "daemonsets"]
    verbs      = ["watch", "list", "get"]
  }
  rule {
    api_groups = ["policy"]
    resources  = ["poddisruptionbudgets"]
    verbs      = ["watch", "list"]
  }
  rule {
    api_groups = ["apps"]
    resources  = ["statefulsets", "replicasets", "daemonsets"]
    verbs      = ["watch", "list", "get"]
  }
  rule {
    api_groups = ["storage.k8s.io"]
    resources  = ["storageclasses", "csinodes", "csistoragecapacities", "csidrivers"]
    verbs      = ["watch", "list", "get"]
  }
  rule {
    api_groups = ["batch", "extensions"]
    resources  = ["jobs"]
    verbs      = ["get", "list", "watch", "patch"]
  }
  rule {
    api_groups = ["coordination.k8s.io"]
    resources  = ["leases"]
    verbs      = ["create"]
  }
  rule {
    api_groups     = ["coordination.k8s.io"]
    resource_names = ["cluster-autoscaler"]
    resources      = ["leases"]
    verbs          = ["get", "update"]
  }

  depends_on = [oci_containerengine_node_pool.oci_oke_node_pool]
}

resource "kubernetes_role" "cluster_autoscaler_role" {
  count = local.cluster_autoscaler_enabled ? 1 : 0

  metadata {
    name      = "cluster-autoscaler"
    namespace = "kube-system"
    labels = {
      k8s-addon = "cluster-autoscaler.addons.k8s.io"
      k8s-app   = "cluster-autoscaler"
    }
  }

  rule {
    api_groups = [""]
    resources  = ["configmaps"]
    verbs      = ["create", "list", "watch"]
  }
  rule {
    api_groups     = [""]
    resource_names = ["cluster-autoscaler-status", "cluster-autoscaler-priority-expander"]
    resources      = ["configmaps"]
    verbs          = ["delete", "get", "update", "watch"]
  }

  depends_on = [oci_containerengine_node_pool.oci_oke_node_pool]
}

resource "kubernetes_cluster_role_binding" "cluster_autoscaler_crb" {
  count = local.cluster_autoscaler_enabled ? 1 : 0
  metadata {
    name = "cluster-autoscaler"
    labels = {
      k8s-addon = "cluster-autoscaler.addons.k8s.io"
      k8s-app   = "cluster-autoscaler"
    }
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "cluster-autoscaler"
  }
  subject {
    kind      = "ServiceAccount"
    name      = "cluster-autoscaler"
    namespace = "kube-system"
  }

  depends_on = [oci_containerengine_node_pool.oci_oke_node_pool]
}

resource "kubernetes_role_binding" "cluster_autoscaler_rb" {
  count = local.cluster_autoscaler_enabled ? 1 : 0

  metadata {
    name      = "cluster-autoscaler"
    namespace = "kube-system"
    labels = {
      k8s-addon = "cluster-autoscaler.addons.k8s.io"
      k8s-app   = "cluster-autoscaler"
    }
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = "cluster-autoscaler"
  }
  subject {
    kind      = "ServiceAccount"
    name      = "cluster-autoscaler"
    namespace = "kube-system"
  }

  depends_on = [oci_containerengine_node_pool.oci_oke_node_pool]
}

resource "kubernetes_deployment" "cluster_autoscaler_deployment" {
  count = local.cluster_autoscaler_enabled ? 1 : 0

  metadata {
    name      = "cluster-autoscaler"
    namespace = "kube-system"
    labels = {
      app = "cluster-autoscaler"
    }
  }

  spec {
    replicas = 3

    selector {
      match_labels = {
        app = "cluster-autoscaler"
      }
    }

    template {
      metadata {
        labels = {
          app = "cluster-autoscaler"
        }
        annotations = {
          "prometheus.io/scrape" = true
          "prometheus.io/port"   = 8085
        }
      }

      spec {
        service_account_name = "cluster-autoscaler"

        container {
          image = local.cluster_autoscaler_image
          name  = "cluster-autoscaler"

          resources {
            limits = {
              cpu    = "100m"
              memory = "300Mi"
            }
            requests = {
              cpu    = "100m"
              memory = "300Mi"
            }
          }
          command = compact([
            "./cluster-autoscaler",
            "--v=${local.cluster_autoscaler_log_level_verbosity}",
            "--stderrthreshold=info",
            "--cloud-provider=${local.cluster_autoscaler_cloud_provider}",
            "--max-node-provision-time=${local.cluster_autoscaler_max_node_provision_time}",
            "--nodes=${var.np1_autoscaler_min_nodes}:${var.np1_autoscaler_max_nodes}:${oci_containerengine_node_pool.oci_oke_node_pool[0].id}",
            var.node_pool_count >= 2 ? "--nodes=${var.np2_autoscaler_min_nodes}:${var.np2_autoscaler_max_nodes}:${oci_containerengine_node_pool.oci_oke_node_pool[1].id}" : "",
            var.node_pool_count >= 3 ? "--nodes=${var.np3_autoscaler_min_nodes}:${var.np3_autoscaler_max_nodes}:${oci_containerengine_node_pool.oci_oke_node_pool[1].id}" : "",
            "--scale-down-delay-after-add=${local.cluster_autoscaler_scale_down_delay_after_add}",
            "--scale-down-unneeded-time=${local.cluster_autoscaler_scale_down_unneeded_time}",
            "--unremovable-node-recheck-timeout=${local.cluster_autoscaler_unremovable_node_recheck_timeout}",
            "--balance-similar-node-groups",
            "--balancing-ignore-label=displayName",
            "--balancing-ignore-label=hostname",
            "--balancing-ignore-label=internal_addr",
            "--balancing-ignore-label=oci.oraclecloud.com/fault-domain"
          ])
          image_pull_policy = "Always"
          env {
            name  = "OKE_USE_INSTANCE_PRINCIPAL"
            value = "true"
          }
          env {
            name  = "OCI_SDK_APPEND_USER_AGENT"
            value = "oci-oke-cluster-autoscaler"
          }
        }
      }
    }
  }

  depends_on = [
    oci_containerengine_node_pool.oci_oke_node_pool,
    helm_release.metrics_server
  ]
}

resource "kubernetes_pod_disruption_budget_v1" "core_dns_pod_disruption_budget" {
  count = local.cluster_autoscaler_enabled ? 1 : 0

  metadata {
    name      = "coredns-pdb"
    namespace = "kube-system"
    labels = {
      k8s-app   = "cluster-autoscaler"
    }
  }
  spec {
    max_unavailable = "1"
    selector {
      match_labels = {
        k8s-app= "kube-dns"
      }
    }
  }

  depends_on = [oci_containerengine_node_pool.oci_oke_node_pool]
}
