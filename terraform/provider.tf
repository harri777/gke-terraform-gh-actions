provider "google" {
  credentials = var.google_sa_key
  project     = var.project
  region      = var.region
}

provider "google-beta" {
  credentials = var.google_sa_key
  project     = var.project
  region      = var.region
}