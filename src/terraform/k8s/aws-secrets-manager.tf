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

# Modify your locals block
locals {
  secrets = {
    "airflow-portal-dev-connection-string" = var.airflow_connection_string
    "airflow-app-dev-fernet-key" = var.airflow_fernet_key
  }
}

# Then modify your kubernetes_manifest resource
resource "kubernetes_manifest" "secret_provider_class" {
  manifest = {
    apiVersion = "secrets-store.csi.x-k8s.io/v1"
    kind = "SecretProviderClass"
    metadata = {
      name = "${var.application_name}-${var.environment_name}-secret-provider-class"
      namespace = var.k8s_namespace
    }
    spec = {
      provider = "aws"
      parameters = {
        objects = yamlencode([
          {
            objectName = "airflow-portal-dev-connection-string"  # Changed from airflow-app-dev
            objectType = "kubernetes.io/secret"
            objectData = [
                {
                    key = "connection"
                    value = local.secrets["airflow-portal-dev-connection-string"]  # Changed from airflow-app-dev
                }
            ]
          },
          {
            objectName = "airflow-app-dev-fernet-key"
            objectType = "kubernetes.io/secret"
            objectData = [
              {
                key = "fernet_key"
                value = local.secrets["airflow-app-dev-fernet-key"]
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
                    objectName = "airflow-portal-dev-connection-string"  # Changed from airflow-app-dev
                }
            ]
            secretName = "airflow-portal-dev-connection-string"  # Changed from airflow-app-dev
            type = "Opaque"
        },
        {
          data = [
            {
              key = "fernet_key"
              objectName = "airflow-app-dev-fernet-key"
            }
          ]
          secretName = "airflow-app-dev-fernet-key"
          type = "Opaque"
        }
      ]
    }
  }
  depends_on = [
    null_resource.wait_for_crds
  ]
}