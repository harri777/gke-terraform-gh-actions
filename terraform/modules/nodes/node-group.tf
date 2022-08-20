resource "google_container_node_pool" "development-nodepool-01" {
  name        = format("%s-nodepool-01", var.cluster_name)
  location    = var.location
  cluster     = var.development_cluster.name
  node_count  = var.initial_node_count

  node_config {
    preemptible  = true
    machine_type = var.machine_type

    metadata = {
      disable-legacy-endpoints = "true"
    }

    labels = {
      team = "sre-challenge"
    }

    oauth_scopes = [
      "https://www.googleapis.com/auth/devstorage.read_only",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]
  }

  management {
    auto_repair  = true
    auto_upgrade = true
  }

  autoscaling {
    min_node_count = 2
    max_node_count = var.max_node_count
  }
}