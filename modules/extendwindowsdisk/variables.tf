##################### Variables ###############################


variable "ipv4_subnet" {
  description = "IPv4 subnet for vNIC configuration"
}

variable "ipv4_subnet_index" {
  description = "IPv4 subnet index for vNIC configuration"
}

variable "admin_password" {
	description = "The Administrator user's Password"
}

variable "dependsOn" {
  description = "depends On variable for VM creation"
  default     = true
}
################ Data Segment #####################
