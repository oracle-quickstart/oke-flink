# Copyright (c) 2021, 2023, Oracle and/or its affiliates. All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at http://oss.oracle.com/licenses/upl. 

locals {
  deployment_name     = "kps"
  vars                = { "region" = var.region, "tenancy_ocid" = var.tenancy_ocid }
  scrape_configs      = flatten([for i in fileset("${path.module}/templates", "*.scrapeConfigs.yaml") : file("${path.module}/templates/${i}")])
  grafana_datasources = flatten([for i in fileset("${path.module}/templates", "grafana.*.datasource.yaml") : yamldecode(templatefile("${path.module}/templates/${i}", local.vars))])
  grafana_dashboards  = flatten([for i in fileset("${path.module}/templates", "grafana.*.dashboard.json") : { "name" = i, "label" = split(".", i)[1] }])
  grafana_plugins     = file("${path.module}/templates/grafana.plugins.yaml")
}

resource "random_password" "grafana_password" {
  count            = local.enable_monitoring_stack ? 1 : 0
  length           = 20
  special          = true
  override_special = "#$%&@!_+=./;:][{}]"
}

output "grafana_password" {
  value     = local.enable_monitoring_stack ? random_password.grafana_password[0].result : ""
  sensitive = true
}

resource "helm_release" "kube_prometheus_stack" {
  count            = local.enable_monitoring_stack ? 1 : 0
  name             = local.deployment_name
  repository       = "https://prometheus-community.github.io/helm-charts"
  chart            = "kube-prometheus-stack"
  namespace        = "monitoring"
  version          = "45.8.0"
  wait             = false
  create_namespace = true

  set {
    name  = "prometheus.prometheusSpec.additionalScrapeConfigs"
    value = join("\n", local.scrape_configs)
  }

  # set {
  #   name  = "grafana.sidecar.datasources.defaultDatasourceEnabled"
  #   value = false
  # }

  set {
    name  = "grafana.adminPassword"
    value = random_password.grafana_password[0].result
  }

  values = [
    yamlencode({ "grafana" = {
      "additionalDataSources" = local.grafana_datasources,
      "plugins"               = yamldecode(local.grafana_plugins)
    } })
  ]

  depends_on = [
    oci_containerengine_node_pool.oci_oke_node_pool
  ]
}

resource "kubernetes_config_map_v1" "grafana_dashboards" {
  count = local.enable_monitoring_stack ? length(local.grafana_dashboards) : 0

  metadata {
    name      = "${local.deployment_name}-grafana-${local.grafana_dashboards[count.index].label}"
    namespace = "monitoring"
    labels = {
      "grafana_dashboard" = "1"
    }
  }

  data = {
    "${local.grafana_dashboards[count.index].name}" = "${file("${path.module}/templates/${local.grafana_dashboards[count.index].name}")}"
  }
  depends_on = [
    helm_release.kube_prometheus_stack
  ]
}

resource "kubernetes_config_map_v1" "grafana_plugins" {
  count = local.enable_monitoring_stack ? 1 : 0

  metadata {
    name      = "${local.deployment_name}-grafana-plugins"
    namespace = "monitoring"
    labels = {
      "grafana_plugin" = "1"
    }
  }

  data = {
    "plugins" = local.grafana_plugins
  }

  depends_on = [
    helm_release.kube_prometheus_stack
  ]
}
