module "network" {
  source = "./modules/network"
  
  cluster_name  = var.cluster_name
  region        = var.region
}

module "master" {
  source = "./modules/cluster"

  cluster_name    = var.cluster_name
  location        = var.location

  cluster_vpc     = module.network.vpc
  cluster_subnet  = module.network.subnet
}

module "nodes" {
  source = "./modules/nodes"

  cluster_name        = var.cluster_name
  location            = var.location
  machine_type        = var.machine_type
  initial_node_count  = var.initial_node_count
  max_node_count      = var.max_node_count
  development_cluster = module.master.development_cluster
}

module "disk" {
  source = "./modules/disk"
}
