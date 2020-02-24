data "vsphere_datacenter" "dc" {
  name = "dc0"
}

data "vsphere_datastore" "datastore" {
  name          = "ds0"
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_resource_pool" "pool" {
  name          = "battleSchool"
  datacenter_id = data.vsphere_datacenter.dc.id
}

# Default external network is the "VM Network" that ships with ESXi
# This will also be the default "vsphere_network" for ease of use w/ environments

data "vsphere_network" "network" {
  name          = "VM Network"
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_network" "external_network" {
  name          = "VM Network"
  datacenter_id = data.vsphere_datacenter.dc.id
}

# The default template for our machines will be Ubuntu Server (Bionic LTS)
data "vsphere_virtual_machine" "kali_template" {
  name          = "cs110_kali_template"
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_virtual_machine" "windows_template" {
  name          = "cs110_icecast_template"
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_host" "esxi_host"{
  name = "10.0.0.161"
  datacenter_id = data.vsphere_datacenter.dc.id
}