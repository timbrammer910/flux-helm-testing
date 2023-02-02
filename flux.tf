# Flux namespace
resource "kubernetes_namespace" "flux" {
  metadata {
    name = "flux"
  }

  lifecycle {
    ignore_changes = [
      metadata[0].labels,
    ]
  }

  depends_on = [
    google_container_cluster.cluster,
    google_container_node_pool.cluster_nodes
  ]
}

# Generate manifests
data "flux_install" "data" {
  target_path    = "clusters/my-cluster"
  namespace = "flux"
  network_policy = false
}


# Split yaml into documents
data "kubectl_file_documents" "install_manifests" {
  content = data.flux_install.data.content
}

# yaml decode manifest  document list
locals {
  apply = [ for v in data.kubectl_file_documents.install_manifests.documents : {
      data: yamldecode(v)
      content: v
    }
  ]
}

# Apply manifests on the cluster
resource "kubectl_manifest" "apply" {
  for_each   = { for v in local.apply : lower(join("/", compact([v.data.apiVersion, v.data.kind, lookup(v.data.metadata, "namespace", ""), v.data.metadata.name]))) => v.content }
  depends_on = [kubernetes_namespace.flux]
  yaml_body = each.value
}

resource "kubectl_manifest" "flux_git_repo_source" {
    yaml_body = <<YAML
apiVersion: source.toolkit.fluxcd.io/v1beta2
kind: GitRepository
metadata:
  name: flux-helm-test
  namespace: "${kubernetes_namespace.flux.metadata[0].name}"
spec:
  interval: 1m
  url: https://github.com/timbrammer910/flux-helm-testing
  ref:
    branch: master
YAML

    depends_on = [kubectl_manifest.apply]
}

resource "kubectl_manifest" "flux_nginx_helm_release" {
    yaml_body = <<YAML
apiVersion: helm.toolkit.fluxcd.io/v2beta1
kind: HelmRelease
metadata:
  name: nginx
  namespace: default
spec:
  interval: 1m
  chart:
    spec:
      chart: ./nginx-chart
      ReconcileStragey: Revision
      sourceRef:
        kind: GitRepository
        name: "${kubectl_manifest.flux_git_repo_source.name}"
        namespace: "${kubernetes_namespace.flux.metadata[0].name}"
      interval: 1m
  test:
    enable: true

YAML

    depends_on = [kubectl_manifest.flux_git_repo_source]
}
