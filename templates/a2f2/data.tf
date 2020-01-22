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
# This will also be the default "vsphere_network" for ease of use w/ templates

data "vsphere_network" "network" {
  name          = "VM Network"
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_external_network" "network" {
  name          = "VM Network"
  datacenter_id = data.vsphere_datacenter.dc.id
}

# The default template for our machines will be Ubuntu Server (Bionic LTS)
data "vsphere_virtual_machine" "template" {
  name          = "ubuntu_server_template"
  datacenter_id = data.vsphere_datacenter.dc.id
}