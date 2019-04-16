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

variable "admin_user" {
	description = "The Administrator user name"
  default     = "Administrator"
}

variable "admin_password" {
	description = "The Administrator user's Password"
  default     = "Passw0rd!"
}

variable "network_label" {
  description = "vSphere Port Group or Network label for Virtual Machine's vNIC"
}

variable "ipv4_subnet" {
  description = "IPv4 subnet for vNIC configuration"
}

variable "ipv4_subnet_index" {
  description = "IPv4 subnet index for vNIC configuration"
}

variable "create_vm_folder" {
  description = "A vSphere folder need to be create or it is precreated"
  default     = true
}

#variable "domain_name" {
#	description = "The Active Directory Domain Name"
#}

#variable "domainjoin_user" {
#	description = "A user with permissions to join the Active Directory"
#}

#variable "domainjoin_password" {
#	description = "The password for the Domain join user"
#}

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

variable "dependsOn" {
  description = "depends On variable for VM creation"
  default     = true
}

################ Data Segment #####################

data "vsphere_datacenter" "datacenter" {
  name = "${var.datacenter}"
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

data "vsphere_virtual_machine" "template" {
  name          = "${var.vm_template}"
  datacenter_id = "${data.vsphere_datacenter.datacenter.id}"
}
