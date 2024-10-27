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

    strategy {
      type = "RollingUpdate"
      rolling_update {
        max_surge       = 1
        max_unavailable = 0
      }
    }

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

        volume {
          name = "pod-template"
          config_map {
            name = kubernetes_config_map.pod_template.metadata[0].name
          }
        }

        container {
          image = "${data.aws_caller_identity.current.account_id}.dkr.ecr.${var.primary_region}.amazonaws.com/${var.airflow_image.name}:${var.airflow_image.version}"
          name  = local.airflow_name

          resources {
            limits = {
              cpu    = "1000m"
              memory = "1Gi"
            }
            requests = {
              cpu    = "500m"
              memory = "512Mi"
            }
          }

          port {
            container_port = 8080
          }

          volume_mount {
            name       = "secrets-store-inline"
            mount_path = "/mnt/secrets-store"
            read_only  = true
          }

          volume_mount {
            name       = "pod-template"
            mount_path = "/opt/airflow/pod_template.yaml"
            sub_path   = "pod_template.yaml"
            read_only  = true
          }

          liveness_probe {
            http_get {
              path = "/health"
              port = 8080
            }
            initial_delay_seconds = 60
            period_seconds       = 20
          }

          readiness_probe {
            http_get {
              path = "/health"
              port = 8080
            }
            initial_delay_seconds = 30
            period_seconds       = 10
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
                name = "airflow-connection-string"
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
            value = "KubernetesExecutor"  # Changed from LocalExecutor
          }

          # Add K8s configuration
          env {
            name  = "AIRFLOW__KUBERNETES__NAMESPACE"
            value = var.k8s_namespace
          }

          env {
            name  = "AIRFLOW__KUBERNETES__WORKER_CONTAINER_REPOSITORY"
            value = "${data.aws_caller_identity.current.account_id}.dkr.ecr.${var.primary_region}.amazonaws.com/${var.airflow_image.name}"
          }

          env {
            name  = "AIRFLOW__KUBERNETES__WORKER_CONTAINER_TAG"
            value = var.airflow_image.version
          }

          env {
            name  = "AIRFLOW__KUBERNETES__DELETE_WORKER_PODS"
            value = "True"
          }

          env {
            name  = "AIRFLOW__KUBERNETES__POD_TEMPLATE_FILE"
            value = "/opt/airflow/pod_template.yaml"
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
