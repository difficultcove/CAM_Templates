##################### Variables ###############################


variable "ssh_user" {
  description = "The user for ssh connection, which is default in template"
  default     = "root"
}

variable "ssh_user_private_key" {
  description = "The user private key for ssh connection, which is default in template"
}

variable "dependsOn" {
  description = "depends On variable for VM creation"
  default     = true
}
################ Data Segment #####################
