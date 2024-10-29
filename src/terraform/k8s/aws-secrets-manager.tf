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

resource "null_resource" "wait_for_crds" {
  provisioner "local-exec" {
    command = "kubectl wait --for=condition=established crd/secretproviderclasses.secrets-store.csi.x-k8s.io --timeout=120s"
  }

  depends_on = [
    helm_release.csi_secrets_store,
    helm_release.aws_secrets_provider
  ]
}

locals {
  secrets = {
    "airflow-portal-dev-connection-string" = "airflow-portal-dev-connection-string"
    "airflow-portal-dev-fernet-key" = "airflow-portal-dev-fernet-key"
  }
}

resource "kubernetes_manifest" "secret_provider_class" {
  manifest = {
    apiVersion = "secrets-store.csi.x-k8s.io/v1"
    kind = "SecretProviderClass"
    metadata = {
      name = "$airflow-portal-dev-secret-provider-class"
      namespace = var.k8s_namespace
    }
    spec = {
      provider = "aws"
      parameters = {
        objects = yamlencode([
          {
            objectName = "airflow-portal-dev-connection-string"
            objectType = "secretsmanager"
            objectData = [
              {
                key = "airflow-portal-dev-connection-string"
                objectAlias = "airflow-portal-dev-connection-string"  # Add this line
              }
            ]
          },
          {
            objectName = "airflow-portal-dev-fernet-key"
            objectType = "secretsmanager"
            objectData = [
              {
                key = "airflow-portal-dev-fernet-key"
                objectAlias = "airflow-portal-dev-fernet-key"  # Add this line
              }
            ]
          }
        ])
      }
      secretObjects = [
        {
          data = [
            {
              key = "connection"
              objectName = "airflow-portal-dev-connection-string"
            }
          ]
          secretName = "airflow-portal-dev-connection-string"
          type = "Opaque"
        },
        {
          data = [
            {
              key = "fernet_key"
              objectName = "airflow-portal-dev-fernet-key"
            }
          ]
          secretName = "airflow-portal-dev-fernet-key"
          type = "Opaque"
        }
      ]
    }
  }
  depends_on = [
    null_resource.wait_for_crds
  ]
}