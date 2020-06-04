locals {
  # How many vuln-attacker pairs do we want per class
  # num_environments = 12
  num_environments = 2 # test case
  # How many classes are we building for
  num_classes = 1
}




# Create an internal switch for the demo
resource "vsphere_host_virtual_switch" "demo_switch" {
  # We're making one of these for each class that has demos at once
  # count = local.num_classes
  count = 1
  active_nics = ["vmnic0"]
  host_system_id = data.vsphere_host.esxi_host.id
  name = format("cs110_demo_switch_%d", count.index)
  # we actually want this to link to an external network
  network_adapters = ["vmnic0"]
  standby_nics = []

}

# Create a port group for each team
resource "vsphere_host_port_group" "demo_pg" {
  # count = local.num_classes
  count = 1
  name = format("cs110%d_internal", count.index)
  host_system_id = data.vsphere_host.esxi_host.id
  # virtual_switch_name = vsphere_host_virtual_switch.demo_switch[count.index].name
  virtual_switch_name = vsphere_host_virtual_switch.demo_switch.name
}

# Pull the resultant network data from this port group.
data "vsphere_network" "demo_network" {
  datacenter_id = data.vsphere_datacenter.dc.id
  # name = vsphere_host_port_group.demo_pg[count.index].name
  name = vsphere_host_port_group.demo_pg.name
}

resource "vsphere_virtual_machine" "vulnbox" {
  count =  local.num_environments
  name             = format("cs110z_vulnbox%d", count.index)
  resource_pool_id = data.vsphere_resource_pool.pool.id
  datastore_id     = data.vsphere_datastore.datastore.id
  wait_for_guest_net_routable = false
  wait_for_guest_net_timeout = 0

  num_cpus = 1
  memory   = 2048

  # Editing vApp properties for this OVA requires a loaded CDROM with client_device=true
  guest_id = data.vsphere_virtual_machine.windows_template.guest_id
  cdrom {
    client_device=true
  }
  scsi_type = data.vsphere_virtual_machine.windows_template.scsi_type


  # External network interface
  network_interface {
    network_id = data.vsphere_network.demo_network.id
    adapter_type = data.vsphere_virtual_machine.windows_template.network_interface_types[0]
  }

  disk {
    # Differs from the guide in that newer versions of Terraform require the key to be 'label' and the value to end in '.vmdk'
    label             = "disk0.vmdk"
    size             = data.vsphere_virtual_machine.windows_template.disks[0].size
    eagerly_scrub    = data.vsphere_virtual_machine.windows_template.disks[0].eagerly_scrub
    thin_provisioned = data.vsphere_virtual_machine.windows_template.disks[0].thin_provisioned
  }

  clone {

    template_uuid = data.vsphere_virtual_machine.windows_template.id

    customize {
      # External network interface
      # Follows the order of network_interface declarations in the vm block
      network_interface {
        # TODO: Replace with an internal NAT space OR the IPs that Mr. Harris gives you
        ipv4_address = "10.0.0.${count.index + 164}"
        ipv4_netmask = 24
      }

      }

    }

  # TODO: Merge vapp properties into the customize block
  vapp {
    properties = {
      "hostname"                        = format("cs110_vulnbox%d", count.index)
    }
  }
  custom_attributes {}
}

resource "vsphere_virtual_machine" "attacker" {
  count =  local.num_environments
  name             = format("cs110z_kali%d", count.index)
  resource_pool_id = data.vsphere_resource_pool.pool.id
  datastore_id     = data.vsphere_datastore.datastore.id
  wait_for_guest_net_routable = false
  wait_for_guest_net_timeout = 0

  num_cpus = 1
  memory   = 2048

  # Editing vApp properties for this OVA requires a loaded CDROM with client_device=true
  guest_id = data.vsphere_virtual_machine.kali_template.guest_id
  cdrom {
    client_device=true
  }
  scsi_type = data.vsphere_virtual_machine.kali_template.scsi_type


  # External network interface
  network_interface {
    network_id = data.vsphere_network.demo_network.id
    adapter_type = data.vsphere_virtual_machine.kali_template.network_interface_types[0]
  }

  disk {
    # Differs from the guide in that newer versions of Terraform require the key to be 'label' and the value to end in '.vmdk'
    label             = "disk0.vmdk"
    size             = data.vsphere_virtual_machine.kali_template.disks[0].size
    eagerly_scrub    = data.vsphere_virtual_machine.kali_template.disks[0].eagerly_scrub
    thin_provisioned = data.vsphere_virtual_machine.kali_template.disks[0].thin_provisioned
  }

  clone {
    template_uuid = data.vsphere_virtual_machine.kali_template.id

    customize {
      # External network interface
      # Follows the order of network_interface declarations in the vm block
      network_interface {
        # TODO: Replace with an internal NAT space OR the IPs that Mr. Harris gives you
        ipv4_address = "10.0.0.${count.index + 164}"
        ipv4_netmask = 24
      }

    }
  }
  # TODO: Merge vapp properties into the customize block
  vapp {
    properties = {
      "hostname"                        = format("cs110_kali%d", count.index)
      "password"                        = "icecastisbad"
      "public-keys"                     = ""

    }
  }
  custom_attributes {}
}
