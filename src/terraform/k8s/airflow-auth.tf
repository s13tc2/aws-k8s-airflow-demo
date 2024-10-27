# ConfigMap for Airflow configuration
resource "kubernetes_config_map" "airflow" {
  metadata {
    name      = "${local.airflow_name}-config"
    namespace = var.k8s_namespace
  }

  data = {
    AIRFLOW__CORE__LOAD_EXAMPLES = "false"
    AIRFLOW__WEBSERVER__BASE_URL = "http://localhost:8080"
    AIRFLOW__CORE__EXECUTOR      = "KubernetesExecutor"
    
    # K8s specific configs
    AIRFLOW__KUBERNETES__NAMESPACE = var.k8s_namespace
    AIRFLOW__KUBERNETES__DELETE_WORKER_PODS = "True"
    AIRFLOW__KUBERNETES__WORKER_PODS_CREATION_BATCH_SIZE = "1"
  }
}

# ConfigMap for pod template
resource "kubernetes_config_map" "pod_template" {
  metadata {
    name      = "airflow-pod-template"
    namespace = var.k8s_namespace
  }

  data = {
    "pod_template.yaml" = <<-EOT
      apiVersion: v1
      kind: Pod
      metadata:
        name: dummy-name
      spec:
        containers:
          - args: []
            command: []
            env: []
            envFrom: []
            image: dummy-image
            imagePullPolicy: IfNotPresent
            name: base
            resources:
              requests:
                cpu: "1"
                memory: "1Gi"
              limits:
                cpu: "2"
                memory: "2Gi"
        serviceAccountName: ${kubernetes_service_account.workload_identity.metadata[0].name}
        securityContext:
          runAsUser: 50000
          fsGroup: 50000
    EOT
  }
}

# If you have any other auth-related resources, they would go here
# For example, service accounts, roles, role bindings, etc.