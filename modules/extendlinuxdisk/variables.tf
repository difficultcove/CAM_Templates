##################### Variables ###############################

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

#Target VM IP address
variable "ipv4_address" {
  type = "string"
}


variable "dependsOn" {
  default = "true"

  description = "Boolean for dependency"
}
