# CS110Z Cyber Attack Capstone

## Objective

The objective of this multi-class demonstration is to provide an interactive environment in which cadets may go through the entire Cyber Attack Methodology using VMs provisioned with Terraform. 

## Background

### Basic Workflow
+ We'll build a separate environment for each pair of individuals. These will each consist of:
    + A `vsphere_host_port_group` that establishes a VM Network on the host.
    + A `vsphere_virtual_machine` for the Vulnerable (Win7) box, containing:
        + A vulnerable (<=2.0.0) version of the IceCast Media Server running as admin
        + A static IP address on the `GREENNET` network
        + A unique hostname and password (randomly generated)
        + Windows RDP enabled and accessible to connections
        + **Important** firewall rules that specifically only allow inbound RDP connections and connections from the Kali IP. This is because we still want cadets to be able to RDP into the Windows machine to watch in horror.
    + A `vsphere_virtual_machine` for the attacker (Kali) box, containing:
        + Randomized credentials for the root user (to prevent foul play)
        + `xrdp` installed (available on apt) and [listening for connections](https://msitpros.com/?p=3209).
        + A static IP address on the `GREENNET` network
        
+ Both of the VMs mentioned above should live within templates on the vSphere host
