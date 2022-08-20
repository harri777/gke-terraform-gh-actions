variable "cluster_name" {
  type = string
}

variable "project" {
  type = string
}

variable "region" {
  default = "us-central1"
}

variable "location" {
  default = "us-central1-c"
}

variable "google_sa_key" {
  type = string
}

variable "initial_node_count" {
  default = 2
}

variable "max_node_count" {
  default = 4
}

variable "machine_type" {
  default = "n1-standard-2"
}