# Programmatically creates a team's infrastructure, to include a router, server, and supporting networking.
# This module accepts the num_teams data value

locals {
  # Eventually, I'd like to make this an input variable
  num_teams = 2
}

# Create an internal switch for the teams
resource "vsphere_host_virtual_switch" "internal_switch" {
  count = local.num_teams
  active_nics = []
  host_system_id = data.vsphere_host.esxi_host.id
  name = format("team%d_switch", count.index)
  network_adapters = []
  standby_nics = []

}

# Create a port group for each team
resource "vsphere_host_port_group" "pg"{
  count = local.num_teams
  name = format("team%d_internal", count.index)
  host_system_id = data.vsphere_host.esxi_host.id
  virtual_switch_name = vsphere_host_virtual_switch.internal_switch[count.index].name

}

# Create network data from these port groups.
data "vsphere_network" "internal" {
  count = local.num_teams
  datacenter_id = data.vsphere_datacenter.dc.id
  name = vsphere_host_port_group.pg[count.index].name
}

resource "vsphere_virtual_machine" "vm" {
  count =  local.num_teams
  name             = format("team%d_router", count.index)
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
    network_id   = data.vsphere_network.external_network.id
    adapter_type = data.vsphere_virtual_machine.template.network_interface_types[0]
  }

  # Internal network interface
  network_interface {
    # Use only the specific internal network we created for this
    network_id   = data.vsphere_network.internal[count.index].id
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

  #TODO: Add static IPs to both networks.
  vapp {
    properties = {
      "hostname"                        = format("team%d_router", count.index)
      "password"                        = "ubuntutest"
      "public-keys"                     = ""

    }
  }
}

