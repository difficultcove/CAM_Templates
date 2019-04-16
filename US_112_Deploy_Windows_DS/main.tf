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

variable "ipv4_subnet_index" {
  description = "IPv4 subnet index for vNIC configuration"
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

################## Modules ###############################

module "deploywindowsvm" {
  source = "github.com/difficultcove/CAM_Templates/modules/deploy-windows-vm-datastore"
#  source = "git::http://9.180.210.11/root/CAM2102.git//modules/deploy-windows-vm-datastore"

  ####### input to Data Segment
  datacenter            = "${var.datacenter}"
  cluster               = "${var.cluster}"
  storage               = "${var.storage}"
  network_label         = "${var.network_label}"
  vm_template           = "${var.vm_template}"

  ####### input to Resource Segment
  name              = "${var.name}"
  vcpu              = "${var.vcpu}"
  memory            = "${var.memory}"
  rootdisksize      = "${var.rootdisksize}"
  ipv4_subnet       = "${var.ipv4_subnet}"
  ipv4_subnet_index = "${var.ipv4_subnet_index}"
  dns_domain        = "${var.dns_domain}"
  dns_server_list   = "${var.dns_server_list}"
  product_key       = "${var.product_key}"
  admin_user        = "${var.admin_user}"
  admin_password    = "${var.admin_password}"
  workgroup         = "${var.workgroup}"
  organization_name = "${var.organization_name}"
  time_zone         = "${var.time_zone}"
  domain_name       = "${var.domain_name}"
  domainjoin_user   = "${var.domainjoin_user}"
  domainjoin_password = "${var.domainjoin_password}"

}
