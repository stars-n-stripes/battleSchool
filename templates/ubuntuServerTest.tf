# Built with help from a guide at 
# https://giedrius.blog/2018/04/23/terraform-vsphere-provider-1-x-now-supports-deploying-ova-files-makes-using-ovftool-on-esxi-hosts-obsolete/

provider "vsphere" {
  user           = "administrator@vsphere.local"
  password       = ""
  vsphere_server = ""

  # If you have a self-signed cert
  allow_unverified_ssl = true
}

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

data "vsphere_external_network" "network" {
  name          = "VM Network"
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_virtual_machine" "template" {
  name          = "ubuntu_server_template"
  datacenter_id = data.vsphere_datacenter.dc.id
}

resource "vsphere_virtual_machine" "vm" {
  name             = "terraform-test"
  resource_pool_id = data.vsphere_resource_pool.pool.id
  datastore_id     = data.vsphere_datastore.datastore.id
  wait_for_guest_net_routable = false
  wait_for_guest_net_timeout = 0
  
  # Slightly swole for routing
  num_cpus = 4
  memory   = 4096
  
  # Editing vApp properties for this OVA requires a loaded CDROM with client_device=true
  guest_id = data.vsphere_virtual_machine.template.guest_id
  cdrom {
    client_device=true
  }
  scsi_type = data.vsphere_virtual_machine.template.scsi_type


  # External network interface
  network_interface {
    network_id   = data.vsphere_external_network.network.id
    adapter_type = data.vsphere_virtual_machine.template.network_interface_types[0]
  }
  
  # Internal network interface
  network_interface {
    network_id   = data.vsphere_internal_network.network.id
    adapter_type = data.vsphere_virtual_machine.template.network_interface_types[0]
  }
  

  disk {
  # Differs from the guide in that newer versions of Terraform require the key to be 'label' and the value to end in '.vmdk'
    label             = "disk0.vmdk"
    size             = data.vsphere_virtual_machine.template.disks[0].size
    eagerly_scrub    = data.vsphere_virtual_machine.template.disks[0].eagerly_scrub
    thin_provisioned = data.vsphere_virtual_machine.template.disks[0].thin_provisioned
  }

  clone {
    template_uuid = data.vsphere_virtual_machine.template.id
  }

  vapp {
    properties = {
      "hostname"                        = "ubuntuServertest"
      "password"                        = "ubuntutest"
	  "public-keys"                     =""

    }
  }
}

