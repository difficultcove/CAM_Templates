##################### Variables ###############################

variable "name" {
  description = "Name of the Virtual Machine"
}

variable "folder" {
  description = "Target vSphere folder for Virtual Machine"
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

variable "domain_name" {
  description = "The DNS domain name for the VM"
  default     = "localdomain"
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

variable "ssh_user" {
  description = "The user for ssh connection, which is default in template"
  default     = "root"
}

variable "ssh_user_password" {
  description = "The user password for ssh connection, which is default in template"
}

variable "create_vm_folder" {
  description = "A vSphere folder need to be create or it is precreated"
  default     = false
}

variable "allow_selfsigned_cert" {
  description = "Communication with vsphere server with self signed certificate"
  default     = false
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

############### Optinal settings in provider ##########
provider "vsphere" {
  version              = "~> 1.3"
  allow_unverified_ssl = "${var.allow_selfsigned_cert}"
}

################## Resources ###############################

#
# Create vSphere folder for the Virtual Machine
#
resource "vsphere_folder" "folder_vm_1" {
  count         = "${var.create_vm_folder}"
  path          = "${var.folder}"
  datacenter_id = "${data.vsphere_datacenter.datacenter.id}"
  type          = "vm"
}

#
# Create VM with single vnic on a network label by cloning
#
resource "vsphere_virtual_machine" "vm_1" {
  depends_on        = ["vsphere_folder.folder_vm_1"]
  name              = "${var.name}"
  folder            = "${var.folder}"
  num_cpus          = "${var.vcpu}"
  memory            = "${var.memory}"
  resource_pool_id  = "${data.vsphere_resource_pool.pool.id}"
  datastore_id      = "${data.vsphere_datastore.datastore.id}"
  guest_id          = "${data.vsphere_virtual_machine.template.guest_id}"
  num_cores_per_socket = 1
  cpu_hot_add_enabled  = true
  cpu_hot_remove_enabled = true
  memory_hot_add_enabled = true

  network_interface {
      network_id    = "${data.vsphere_network.network.id}"
  }

  disk {
    name              = "${var.name}.vmdk"
    size              = "${var.rootdisksize}"
    datastore_id      = "${data.vsphere_datastore.datastore.id}"
    thin_provisioned  = "${data.vsphere_virtual_machine.template.disks.0.thin_provisioned}"
  }

  clone {
    template_uuid = "${data.vsphere_virtual_machine.template.id}"

    customize {
      timeout = "60"
      linux_options {
        host_name = "${var.name}"
        domain    = "${var.domain_name}"
      }

      network_interface {
        ipv4_address = "${var.ipv4_address}"
#        ipv4_netmask = "${var.ipv4_prefix_length}"
        ipv4_netmask = "${var.network_label == "NLAB_MGMT_0210" ? "25" : "24"}"
      }

#      ipv4_gateway = "${var.ipv4_gateway}"
      ipv4_gateway = "${var.network_label == "NLAB_MGMT_0210" ? "9.180.210.1" : "172.24.19.1"}"
    }
  }
}
