
provider "vsphere" {
  version              = "~> 1.3"
  allow_unverified_ssl = "${var.allow_selfsigned_cert}"
}

variable "dependsOn" {
  description = "depends On variable for VM creation"
  default     = true
}

variable "datacenter" {
  description = "VMware datacenter name"
}

variable "folder" {
  description = "Target vSphere folder for ICP Virtual Machines"
}

data "vsphere_datacenter" "dc" {
  name = "${var.datacenter}"
}


################## Resources ###############################
# Create vSphere Folder
resource "vsphere_folder" "folder_vm_1" {
  path          = "${var.folder}"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
  type          = "vm"
}
