resource "helm_release" "ingress" {
  name             = "ingress"
  repository       = "https://charts.bitnami.com/bitnami"
  chart            = "nginx-ingress-controller"
  create_namespace = true
  namespace        = "ingress-nginx"

  # Basic LoadBalancer configuration
  set {
    name  = "service.type"
    value = "LoadBalancer"
  }

  set {
    name  = "service.annotations"
    value = "service.beta.kubernetes.io/aws-load-balancer-type: nlb"
  }

  # Timeout configurations for Airflow
  set {
    name  = "controller.config.proxy-read-timeout"
    value = "3600"  # 1 hour timeout for long-running tasks
  }

  set {
    name  = "controller.config.proxy-send-timeout"
    value = "3600"
  }

  set {
    name  = "controller.config.proxy-connect-timeout"
    value = "60"
  }

  # General performance configurations
  set {
    name  = "controller.config.use-forwarded-headers"
    value = "true"
  }

  set {
    name  = "controller.config.use-gzip"
    value = "true"
  }

  # Buffer configurations
  set {
    name  = "controller.config.proxy-buffer-size"
    value = "8k"
  }

  set {
    name  = "controller.config.proxy-buffers-number"
    value = "4"
  }

  # Worker configurations
  set {
    name  = "controller.config.worker-processes"
    value = "auto"
  }

  set {
    name  = "controller.config.max-worker-connections"
    value = "4096"
  }
}
