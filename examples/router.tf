# This module configures a single server on vsphere

# Inputs
variable "name" {}

variable "datacenter" { default = "" }
variable "datastore" { default = "" }
variable "resource_pool" { default = "" }
variable "folder" {}

variable "template" { default = "" }
variable "guest_id" { default = "" }

variable "num_cpus" { default = 4 }
variable "memory" { default = 4096 }

variable "wait_for_guest_net_timeout" { default = 0 }
variable "wait_for_guest_net_routable" { default = false }

variable "host_name" {}
variable "domain" {}
variable "ipv4_gateway" {}

variable "internal_network" {}
variable "internal_ipv4_address" {}
variable "internal_ipv4_mask" { default = 24 }

variable "external_network" {}
variable "external_ipv4_address" {}
variable "external_ipv4_mask" { default = 24 }



data "vsphere_datacenter" "dc" {
  name = "${var.datacenter}"
}

data "vsphere_datastore" "datastore" {
  name          = "${var.datastore}"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

data "vsphere_resource_pool" "pool" {
  name          = "${var.resource_pool}"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

data "vsphere_network" "internal_network" {
  name          = "${var.internal_network}"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

data "vsphere_network" "external_network" {
  name          = "${var.external_network}"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

data "vsphere_virtual_machine" "template" {
  name          = "${var.template}"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

# Create a VM
resource "vsphere_virtual_machine" "vm" {
  name             = "${var.name}"
  resource_pool_id = "${data.vsphere_resource_pool.pool.id}"
  datastore_id     = "${data.vsphere_datastore.datastore.id}"
  folder           = "${var.folder}"

  num_cpus = "${var.num_cpus}"
  memory   = "${var.memory}"
  guest_id = "${var.guest_id}"

  wait_for_guest_net_timeout  = "${var.wait_for_guest_net_timeout}"
  wait_for_guest_net_routable = "${var.wait_for_guest_net_routable}"

  network_interface {
    network_id = "${data.vsphere_network.internal_network.id}"
  }

  network_interface {
    network_id = "${data.vsphere_network.external_network.id}"
  }

  disk {
    label            = "disk0"
    size             = "${data.vsphere_virtual_machine.template.disks.0.size}"
    eagerly_scrub    = "${data.vsphere_virtual_machine.template.disks.0.eagerly_scrub}"
    thin_provisioned = "${data.vsphere_virtual_machine.template.disks.0.thin_provisioned}"
  }


  clone {
    template_uuid = "${data.vsphere_virtual_machine.template.id}"

    customize {

      linux_options {
        host_name = "${var.host_name}"
        domain    = "${var.domain}"
      }

      network_interface {
        ipv4_address = "${var.internal_ipv4_address}"
        ipv4_netmask = "${var.internal_ipv4_mask}"
      }

      network_interface {
        ipv4_address = "${var.external_ipv4_address}"
        ipv4_netmask = "${var.external_ipv4_mask}"
      }

      ipv4_gateway = "${var.ipv4_gateway}"

    }

  }

  lifecycle {
    ignore_changes = ["annotation"]
  }

}
