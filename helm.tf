resource "helm_release" "flux_helm_cr" {
  name  = "flux-helm-cr"
  chart = "${path.module}/flux-chart"
}

resource "helm_release" "flux_helm_operator" {
  name       = "flux-helm-operator"
  repository = "https://charts.fluxcd.io"
  chart      = "helm-operator"
  namespace  = kubernetes_namespace.flux.metadata[0].name

  set {
    name  = "helm.versions"
    value = "v3"
  }

  depends_on = [
      helm_release.flux_helm_cr,
      kubernetes_namespace.flux
  ]
}

resource "helm_release" "helm_within_a_config_within_a_helm_lol" {
  name  = "podinfo"
  chart = "${path.module}/podinfo-chart"

  set {
    name  = "trigger"
    value = tostring(null_resource.chart-update.id)
    type  = "string"
  }

  depends_on = [
      helm_release.flux_helm_operator
  ]
}

resource "null_resource" "chart-update" {
  triggers = {
    chart = sha1(join("", [for f in fileset("${path.module}/podinfo-chart", "**") : filesha1("${path.module}/podinfo-chart/${f}")]))
  }
}