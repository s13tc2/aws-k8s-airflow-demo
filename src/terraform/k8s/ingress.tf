resource "kubernetes_ingress_v1" "airflow" {
  metadata {
    name      = "${local.airflow_name}-ingress"
    namespace = var.k8s_namespace
    
    annotations = {
      "kubernetes.io/ingress.class" = "nginx"
      
      # Timeout settings
      "nginx.ingress.kubernetes.io/proxy-read-timeout"    = "3600"
      "nginx.ingress.kubernetes.io/proxy-send-timeout"    = "3600"
      "nginx.ingress.kubernetes.io/proxy-connect-timeout" = "3600"
      
      # Stability and performance settings
      "nginx.ingress.kubernetes.io/proxy-buffer-size"     = "128k"
      "nginx.ingress.kubernetes.io/client-max-body-size"  = "50m"
      "nginx.ingress.kubernetes.io/proxy-buffers-number"  = "4"
      
      # Header and proxy configurations
      "nginx.ingress.kubernetes.io/configuration-snippet" = <<-EOF
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_http_version 1.1;
        proxy_set_header Connection keep-alive;
        proxy_pass_request_headers on;
      EOF
    }
  }

  spec {
    ingress_class_name = "nginx"
    
    rule {
      http {
        path {
          path      = "/"
          path_type = "Prefix"
          backend {
            service {
              name = kubernetes_service.airflow.metadata[0].name
              port {
                number = 80
              }
            }
          }
        }
      }
    }
  }

  depends_on = [
    kubernetes_service.airflow,
    helm_release.ingress
  ]
}