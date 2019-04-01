
########################
# Bastion host variables
########################
variable "bastion_host" {
  type = "string"
}

variable "bastion_user" {
  type = "string"
}

variable "bastion_private_key" {
  type = "string"
}

variable "bastion_port" {
  type = "string"
}

variable "bastion_host_key" {
  type = "string"
}

variable "bastion_password" {
  type = "string"
}

##################### Variables ###############################
variable "name" {
  description = "Name prefix of ICP system. master, proxy-n, worker-n and manager will be added"
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
  default     = 1
}

variable "memory" {
  description = "Memory for Virtual Machine in MBs"
  default     = 1024
}

variable "rootdisksize" {
  description = "The Size of the root disk"
  default     = 16
}

variable "network_label" {
  description = "vSphere Port Group or Network label for Virtual Machine's vNIC"
}

variable "ipv4_subnet" {
  description = "IPv4 subnet for vNIC configuration"
}

variable "ipv4_address" {
  description = "IPv4 Address"
}

variable "dns_domain" {
  description = "DNS Domain name"
}

variable "dns_server_list" {
  description = "DNS server list"
  type        = "list"
}

variable "allow_selfsigned_cert" {
  description = "Communication with vsphere server with self signed certificate"
  default     = true
}

variable "admin_user" {
	description = "The Administrator user name"
  default     = "Administrator"
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

variable "product_key" {
	description = "The Windows Product Key"
}

variable "workgroup" {
	description = "The Workgroup for this machine"
  default     = "Workgroup"
}

variable "organization_name" {
	description = "The Organisation Name for this machine"
  default     = "IBM UK Ltd"
}

variable "time_zone" {
	description = "The Time Zone for this machine"
  default     = 85
}

output "dependsOn" { value = "${vsphere_virtual-machine.vm_1.id}" description="Output Parameter when Resource Complete"}

################ Data Segment #####################

data "vsphere_datacenter" "datacenter" {
  name = "${var.datacenter}"
}

data "vsphere_datastore_cluster" "datastore_cluster" {
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

data "vsphere_virtual_machine" "template" {
  name          = "${var.vm_template}"
  datacenter_id = "${data.vsphere_datacenter.datacenter.id}"
}

############### Optinal settings in provider ##########
provider "vsphere" {
  version              =  "~> 1.3"
  allow_unverified_ssl = "${var.allow_selfsigned_cert}"
}

################## Resources ###############################

# Deploy Windows VM in Workgroup

#
# Create VM with single vnic on a network label by cloning
#
# Create VM Server
resource "vsphere_virtual_machine" "vm_1" {
  name                 = "${var.name}"
  num_cpus             = "${var.vcpu}"
  memory               = "${var.memory}"
  resource_pool_id     = "${data.vsphere_resource_pool.pool.id}"
  datastore_cluster_id = "${data.vsphere_datastore_cluster.datastore_cluster.id}"
  guest_id             = "${data.vsphere_virtual_machine.template.guest_id}"
  scsi_type            = "${data.vsphere_virtual_machine.template.scsi_type}"
  scsi_controller_count = 1
  num_cores_per_socket = 1
  cpu_hot_add_enabled  = true
  cpu_hot_remove_enabled = true
  memory_hot_add_enabled = true

  network_interface {
      network_id    = "${data.vsphere_network.network.id}"
  }

  # This section should prevent terraform from rebuilding a VM only on the same datastore that it was created on
#  lifecycle {
#    ignore_changes = [
#      "datastore_id",
#      "disk",
#    ]
#  }

  disk {
#    name              = "${var.name}.vmdk"
    label             = "${var.name}.vmdk"
    size              = "${var.rootdisksize}"
    thin_provisioned  = "${data.vsphere_virtual_machine.template.disks.0.thin_provisioned}"
  }

  clone {
    template_uuid = "${data.vsphere_virtual_machine.template.id}"
    timeout = "110"
    customize {
      timeout = "20"
      windows_options {
				computer_name 				= "${var.name}"
        full_name             = "${var.admin_user}"
				admin_password 				= "${var.admin_password}"
				time_zone							= "${var.time_zone}"
		  	organization_name 		= "${var.organization_name}"
        workgroup             = "${var.workgroup}"
        product_key           = "${var.product_key}"
        #				join_domain 					= "${var.domain_name}"
        #				domain_admin_user 		= "${var.domainjoin_user}"
        #				domain_admin_password = "${var.domainjoin_password}"
      }
      ipv4_gateway = "${cidrhost("${var.ipv4_subnet}", "1")}"
      network_interface {
        ipv4_address = "${var.ipv4_subnet}"
        ipv4_address = "${var.ipv4_address}"
      }
    }
  }
}
