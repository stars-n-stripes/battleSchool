variable "password" {}
variable "vsphere_server" {}

provider "vsphere" {
  user           = "administrator@vsphere.local"
  password       = var.password
  vsphere_server = var.vsphere_server

  # If you have a self-signed cert (we do right now)
  allow_unverified_ssl = true
}
