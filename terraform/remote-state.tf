terraform {
  backend "remote" {
    organization = "Harrisson"

    workspaces {
      name = "teste1"
    }
  }
}