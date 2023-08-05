resource "local_file" "kubeconfig" {
  content  = "${data.oci_containerengine_cluster_kube_config.this.content}"
  filename = ".kube/config"
}
