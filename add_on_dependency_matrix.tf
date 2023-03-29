## Copyright © 2023, Oracle and/or its affiliates. 
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

# defines trigger to enable specific components based on selection
locals {
  enable_flink                    = var.enable_flink
  enable_cert_manager             = local.enable_flink || var.enable_cert_manager
  enable_cluster_autoscaler       = var.np1_enable_autoscaler || var.np2_enable_autoscaler || var.np3_enable_autoscaler
  enable_monitoring_stack         = var.enable_monitoring_stack
  enable_metrics_server           = local.enable_cluster_autoscaler || var.enable_metrics_server || local.enable_monitoring_stack
  enable_grafana_flink_dashboards = local.enable_monitoring_stack && local.enable_flink
}