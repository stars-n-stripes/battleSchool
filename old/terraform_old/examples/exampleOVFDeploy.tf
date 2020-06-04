data "vsphere_datacenter" "dc" {
  name = "dc0"
}

data "vsphere_datastore" "datastore" {
  name          = "ds0"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

data "vsphere_resource_pool" "pool" {
  name          = "battleSchool"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

data "vsphere_network" "network" {
  name          = "VM Network"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

data "vsphere_virtual_machine" "tempate_from_ovf" {
  name          = "template_from_ovf"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

resource "vsphere_virtual_machine" "vm" {
  name             = "terraform-test"
  resource_pool_id = "${data.vsphere_resource_pool.pool.id}"
  datastore_id     = "${data.vsphere_datastore.datastore.id}"

  num_cpus = 2
  memory   = 1024
  guest_id = "${data.vsphere_virtual_machine.template.guest_id}"

  scsi_type = "${data.vsphere_virtual_machine.template.scsi_type}"

  network_interface {
    network_id   = "${data.vsphere_network.network.id}"
    adapter_type = "${data.vsphere_virtual_machine.template.network_interface_types[0]}"
  }

  disk {
    name             = "disk0"
    size             = "${data.vsphere_virtual_machine.template.disks.0.size}"
    eagerly_scrub    = "${data.vsphere_virtual_machine.template.disks.0.eagerly_scrub}"
    thin_provisioned = "${data.vsphere_virtual_machine.template.disks.0.thin_provisioned}"
  }

  clone {
    template_uuid = "${data.vsphere_virtual_machine.template_from_ovf.id}"
  }

  vapp {
    properties {
      "guestinfo.hostname"                        = "coreOStest"
      "guestinfo.interface.0.name"                = "ens192"
      "guestinfo.interface.0.ip.0.address"        = "10.0.0.163/24"
      "guestinfo.interface.0.route.0.gateway"     = "10.0.0.1"
      "guestinfo.interface.0.route.0.destination" = "0.0.0.0/0"
      "guestinfo.dns.server.0"                    = "8.8.8.8"
	  "guestinfo.coreos.config.data.encoding"     = "base64"
	  "guestinfo.coreos.config.data"              = "aWduaXRpb24uY29uZmlnCg=="
    }
  }
}