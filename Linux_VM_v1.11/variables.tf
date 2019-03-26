##################### Variables ###############################

variable "name" {
  description = "Name prefix of ICP system. master, proxy-n, worker-n and manager will be added"
}


variable "folder" {
  description = "Target vSphere folder for ICP Virtual Machines"
}

variable "datacenter" {
  description = "Target vSphere datacenter for Virtual Machine creation"
}

variable "cluster" {
  description = "Target vSphere Cluster to host the Virtual Machine"
}

variable "storage" {
  description = "Data storage cluster name for target VMs disks"
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

variable "ipv4_subnet" {
  description = "IPv4 subnet for vNIC configuration"
}

variable "ipv4_subnet_index" {
  description = "IPv4 subnet index for vNIC configuration"
}


variable "ssh_user" {
  description = "The user for ssh connection, which is default in template"
  default     = "root"
}

variable "ssh_password" {
  description = "The password for ssh connection when private key is not used"
  default     = "root"
}

variable "ssh_user_private_key" {
  description = "The user private key for ssh connection, which is default in template"
}

variable "create_vm_folder" {
  description = "A vSphere folder need to be create or it is precreated"
  default     = true
}

variable "allow_selfsigned_cert" {
  description = "Communication with vsphere server with self signed certificate"
  default     = false
}
