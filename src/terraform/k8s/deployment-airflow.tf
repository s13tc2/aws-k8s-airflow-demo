locals {
  airflow_name = "airflow-webserver"
}

resource "kubernetes_deployment" "airflow" {
  metadata {
    name      = local.airflow_name
    namespace = var.k8s_namespace
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = local.airflow_name
      }
    }

    template {
      metadata {
        labels = {
          app = local.airflow_name
        }
      }

      spec {
        service_account_name = kubernetes_service_account.workload_identity.metadata[0].name
        
        volume {
          name = "secrets-store-inline"
          csi {
            driver    = "secrets-store.csi.k8s.io"
            read_only = true
            volume_attributes = {
              "secretProviderClass" = kubernetes_manifest.secret_provider_class.manifest.metadata.name
            }
          }
        }

        container {
          image = "${data.aws_caller_identity.current.account_id}.dkr.ecr.${var.primary_region}.amazonaws.com/${var.web_airflow_image.name}:${var.web_airflow_image.version}"
          name  = local.airflow_name

          port {
            container_port = 8080
          }

          volume_mount {
            name       = "secrets-store-inline"
            mount_path = "/mnt/secrets-store"
            read_only  = true
          }

          env_from {
            config_map_ref {
              name = kubernetes_config_map.airflow.metadata.0.name
            }
          }

          env {
            name = "AIRFLOW__CORE__SQL_ALCHEMY_CONN"
            value_from {
              secret_key_ref {
                name = "airflow-dev-connection-string"
                key  = "airflow-connection-string"
              }
            }
          }

          env {
            name = "AIRFLOW__CORE__FERNET_KEY"
            value_from {
              secret_key_ref {
                name = "airflow-fernet-key"
                key  = "airflow-fernet-key"
              }
            }
          }

          env {
            name  = "AIRFLOW__CORE__EXECUTOR"
            value = "KubernetesExecutor"
          }
        }
      }
    }
  }

  timeouts {
    create = "15m"
    update = "15m"
    delete = "5m"
  }
}

resource "kubernetes_service" "airflow" {
  metadata {
    name      = "${local.airflow_name}-service"
    namespace = var.k8s_namespace
  }

  spec {
    type = "ClusterIP"
    port {
      port        = 80
      target_port = 8080
    }
    selector = {
      app = local.airflow_name
    }
  }
}
