provider "vsphere" {
  user           = "administrator@vsphere.local"
  password       = ""
  vsphere_server = ""

  # If you have a self-signed cert (we do right now)
  allow_unverified_ssl = true
}