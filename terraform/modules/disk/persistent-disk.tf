resource "google_compute_disk" "disk" {
  name  = "redis-disk"
  type  = "pd-ssd"
  zone  = "us-central1-c"
  size = 5

  labels = {
    environment = "dev-redis"
  }
  physical_block_size_bytes = 4096
}