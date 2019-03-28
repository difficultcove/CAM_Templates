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
