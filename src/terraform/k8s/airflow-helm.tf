resource "helm_release" "airflow" {
  name       = var.application_name
  repository = "https://airflow.apache.org"
  chart      = "airflow"
  namespace  = kubernetes_namespace.airflow.metadata[0].name
  version    = "1.11.0"

  set {
    name  = "executor"
    value = "CeleryExecutor"
  }

  set {
    name  = "postgresql.persistence.storageClassName"
    value = kubernetes_storage_class.ebs_sc.metadata[0].name
  }

  set {
    name  = "postgresql.persistence.size"
    value = "8Gi"
  }

  set {
    name  = "webserver.resources.requests.cpu"
    value = "100m"
  }

  set {
    name  = "webserver.resources.requests.memory"
    value = "256Mi"
  }

  set {
    name  = "webserver.resources.limits.cpu"
    value = "200m"
  }

  set {
    name  = "webserver.resources.limits.memory"
    value = "512Mi"
  }

  set {
    name  = "scheduler.resources.requests.cpu"
    value = "100m"
  }

  set {
    name  = "scheduler.resources.requests.memory"
    value = "256Mi"
  }

  set {
    name  = "scheduler.resources.limits.cpu"
    value = "200m"
  }

  values = [
    file("${path.module}/values.yaml")
  ]

  depends_on = [
    kubernetes_namespace.airflow,
    kubernetes_storage_class.ebs_sc
  ]
}

resource "kubernetes_storage_class" "ebs_sc" {
  metadata {
    name = "ebs-sc"
  }
  storage_provisioner     = "ebs.csi.aws.com"
  volume_binding_mode     = "WaitForFirstConsumer"
  allow_volume_expansion  = true
  parameters = {
    type       = "gp3"
    encrypted  = "true"
  }
}