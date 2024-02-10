data "kubectl_path_documents" "home" {
  pattern = "../kubernetes/home/*.yml"
  disable_template = true
}

resource "kubectl_manifest" "home" {
  count = length(data.kubectl_path_documents.home.documents)
  yaml_body = element(data.kubectl_path_documents.home.documents, count.index)
}
