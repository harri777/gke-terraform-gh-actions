resource "google_container_cluster" "development_cluster" {
  provider      = "google-beta"
  name          = var.cluster_name
  network       = var.cluster_vpc.name
  subnetwork    = var.cluster_subnet.name
  location      = var.location

  remove_default_node_pool = true
  initial_node_count       = 1

  network_policy {
    enabled = true
  }

  addons_config {
    istio_config {
      disabled = false
      auth     = "AUTH_MUTUAL_TLS"
    }
  }
}