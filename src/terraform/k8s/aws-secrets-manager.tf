resource "helm_release" "csi_secrets_store" {
  name       = "csi-secrets-store"
  repository = "https://kubernetes-sigs.github.io/secrets-store-csi-driver/charts"
  chart      = "secrets-store-csi-driver"
  namespace  = "kube-system"

  set {
    name  = "syncSecret.enabled"
    value = "true"
  }

  set {
    name  = "installCRDs"
    value = "true"
  }
}

resource "helm_release" "aws_secrets_provider" {
  name       = "secrets-provider-aws"
  repository = "https://aws.github.io/secrets-store-csi-driver-provider-aws"
  chart      = "secrets-store-csi-driver-provider-aws"
  namespace  = "kube-system"

  depends_on = [helm_release.csi_secrets_store]
}

locals {
  secrets = {
    "airflow-dev-connection-string" = "DB_CONNECTION_STRING"
  }
}

resource "null_resource" "wait_for_crds" {
  provisioner "local-exec" {
    command = "kubectl wait --for=condition=established crd/secretproviderclasses.secrets-store.csi.x-k8s.io --timeout=120s"
  }

  depends_on = [
    helm_release.csi_secrets_store,
    helm_release.aws_secrets_provider
  ]
}

resource "kubernetes_manifest" "secret_provider_class" {
  manifest = {
    apiVersion = "secrets-store.csi.x-k8s.io/v1"
    kind       = "SecretProviderClass"
    metadata = {
      name      = "${var.application_name}-${var.environment_name}-secret-provider-class"
      namespace = var.k8s_namespace
    }
    spec = {
      provider = "aws"
      parameters = {
        objects = yamlencode([
          {
            objectName         = "airflow-dev-connection-string"
            objectType         = "secretsmanager"
            objectVersionLabel = "AWSCURRENT"
          }
        ])
      }
      secretObjects = [
        {
          data = [
            {
              key        = "airflow-dev-connection-string"
              objectName = "airflow-dev-connection-string"
            }
          ]
          secretName = "airflow-dev-connection-string"
          type       = "Opaque"
        }
      ]
    }
  }

  depends_on = [
    null_resource.wait_for_crds
  ]
}
