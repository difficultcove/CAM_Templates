##################### Variables ###############################


variable "ssh_user" {
  description = "The user for ssh connection, which is default in template"
  default     = "root"
}

variable "ssh_user_private_key" {
  description = "The user private key for ssh connection, which is default in template"
}

#Target VM IP address
variable "ipv4_subnet" {
  type = "string"
}
variable "ipv4_subnet_index" {
  type = "string"
}

variable "dependsOn" {
  description = "depends On variable for VM creation"
  default     = true
}
################ Data Segment #####################
