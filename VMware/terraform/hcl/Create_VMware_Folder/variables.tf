##################### Variables ###############################

variable "datacenter" {
  description = "Target vSphere datacenter for Virtual Machine creation"
}

variable "folder" {
  description = "Target vSphere folder "
}

variable "allow_selfsigned_cert" {
  description = "Communication with vsphere server with self signed certificate"
  default     = true
}
