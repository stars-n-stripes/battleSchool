# Battle School
> The essence of training is to allow error without consequence. 

*Orson Scott Card, "Ender's Game"*

## Table of Contents

## Purpose
The purpose of Battle School is to provide three main functionalities:
1. An open source framework that builds and deploys interactive demonstrations using hybrid architecture
2. A C2 node for on-demand offense/defense scenarios
3. A knowledgebase for students and other users of the previous two functionalities.

## Requirements
+ We'll have to have a web application that allows access from a few different roles (Admin, Teacher, Student). Django is likely my go-to for this functionality.
+ We need to be able to host a knowledge repository. My two options for this would be to use a Django exstention like [django-wiki](https://github.com/django-wiki/django-wiki) or to set up a separate server that hosts [MediaWiki](https://www.mediawiki.org/wiki/Download)
+ I'll have to set up a separate MySQL database for whatever web application we run. Quick note: it'll need to run classes AND events.
+ It would be nice to containerize the system for easy deployment.
+ We need to make a dashboard for active vm usage (and which classes/events they are associated with).

## Helpful Links

+ [A Guide on Combining Terraform and Ansible for AWS](https://github.com/ernesen/Terraform-Ansible)

+ [More General Terraform-Ansible Blog Post](https://alex.dzyoba.com/blog/terraform-ansible/)

+ [`clong`'s DetectionLab](https://github.com/clong/DetectionLab)

+ [Terraform Examples on GitHub](https://github.com/hashicorp/terraform/tree/master/examples)

+ [The HTML5 Fling for VSphere](https://download3.vmware.com/software/vmw-tools/vsphere_html_client/H5%20Client%20Deployment%20Instructions%20and%20Helpful%20Tips_v28.pdf)

+ [ESXi WebClient Installation Instructions](https://calvin.me/web-interface-for-esxi-without-vcenter/)

+ [VSphere Provider Docs](https://www.terraform.io/docs/providers/vsphere/index.html)

+ [VSphere Docs from VMware](https://docs.vmware.com/en/VMware-vSphere/index.html)

+ [VCSA CLI Deployment Instructions](https://www.vmware.com/content/dam/digitalmarketing/vmware/en/pdf/techpaper/products/vsphere/vmware-vsphere-60-vcenter-server-appliance-cmdline-install-technical-note.pdf)

+ [VA Cyber Range Purpose Statement](https://csrc.nist.gov/CSRC/media/Events/Federal-Information-Systems-Security-Educators-As/documents/24.pdf)

## Lessons Learned
###### Or: The Wall of Shame
+ VCenter is incompatible with ESXi hosts that are of a higher version than it.
+ VMWare publishes specific ISOs for manufacturers.
+ Anything before 6.5 is going to use flash as a default.
+ ChromeOS hates flash.
