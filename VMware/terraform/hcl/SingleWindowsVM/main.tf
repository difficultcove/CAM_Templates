##################### Variables ###############################

variable "name" {
	description = "Name of the Virtual Machine"
}

variable "datacenter" {
	description = "Target vSphere datacenter for Virtual Machine creation"
}

variable "cluster" {
	description = "Target vSphere Cluster to host the Virtual Machine"
}

variable "storage" {
	description = "Data store or storage cluster name for target VMs disks"
}

variable "vm_template" {
	description = "Source VM or Template label for cloning"
}

variable "vcpu" {
	description = "Number of Virtual CPU for the Virtual Machine"
}

variable "memory" {
	description = "Memory for Virtual Machine in MBs"
}

variable "rootdisksize" {
	description = "Root Disk Size"
}

variable "network_label" {
	description = "vSphere Port Group or Network label for Virtual Machine's vNIC"
}

variable "ipv4_address" {
	description = "IPv4 address for vNIC configuration"
}

variable "ipv4_gateway" {
	description = "IPv4 gateway for vNIC configuration"
}

variable "ipv4_prefix_length" {
	description = "IPv4 Prefix length for vNIC configuration"
}

variable "admin_password" {
	description = "The Administrator user's Password"
}

variable "domain_name" {
	description = "The Active Directory Domain Name"
}

variable "domainjoin_user" {
	description = "A user with permissions to join the Active Directory"
}

variable "domainjoin_password" {
	description = "The password for the Domain join user"
}

variable "timezone" {
	description = "The timezone for the new machine"
}

variable "allow_selfsigned_cert" {
    description = "Communication with vsphere server with self signed certificate"
    default = true
}

############### Optional settings in provider ##########
provider "vsphere" {
    version = "~> 1.1"
    allow_unverified_ssl = "${var.allow_selfsigned_cert}"
}

data "vsphere_datacenter" "datacenter" {
  name = "${var.datacenter}"
}

data "vsphere_virtual_machine" "template" {
  name          = "${var.vm_template}"
  datacenter_id = "${data.vsphere_datacenter.datacenter.id}"
}

data "vsphere_datastore" "datastore" {
  name          = "${var.storage}"
  datacenter_id = "${data.vsphere_datacenter.datacenter.id}"
}

data "vsphere_resource_pool" "pool" {
  name          = "${var.cluster}/Resources"
  datacenter_id = "${data.vsphere_datacenter.datacenter.id}"
}

data "vsphere_network" "network" {
  name          = "${var.network_label}"
  datacenter_id = "${data.vsphere_datacenter.datacenter.id}"
}

################## Resources ###############################

#
# Create VM with single vnic on a network label by cloning
#
resource "vsphere_virtual_machine" "vm_1" {
  name   = "${var.name}"
  resource_pool_id = "${data.vsphere_resource_pool.pool.id}"
  datastore_id     = "${data.vsphere_datastore.datastore.id}"
  num_cpus   = "${var.vcpu}"
  memory = "${var.memory}"
  guest_id = "${data.vsphere_virtual_machine.template.guest_id}"

  network_interface {
      network_id = "${data.vsphere_network.network.id}"
  }

  disk {
    name = "${var.name}.vmdk"
    size = "${var.rootdisksize}"
    eagerly_scrub    = "${data.vsphere_virtual_machine.template.disks.0.eagerly_scrub}"
    thin_provisioned = "${data.vsphere_virtual_machine.template.disks.0.thin_provisioned}"
  }

	scsi_type = "${data.vsphere_virtual_machine.template.scsi_type}"

  clone {
    template_uuid = "${data.vsphere_virtual_machine.template.id}"

    customize {
#      linux_options {
#        host_name = "${var.name}"
#        domain    = "test.internal"
#      }
			windows_options {
				computer_name 				= "${var.name}"
				admin_password 				= "${var.admin_password}"
#				join_domain 					= "${var.domain_name}"
#				domain_admin_user 		= "${var.domainjoin_user}"
#				domain_admin_password = "${var.domainjoin_password}"
#				time_zone							= "035"
#				organization_name 		= "Test"
			}

      network_interface {
        ipv4_address = "${var.ipv4_address}"
        ipv4_netmask = "${var.ipv4_prefix_length}"
      }

      ipv4_gateway = "${var.ipv4_gateway}"
    }
  }
}
