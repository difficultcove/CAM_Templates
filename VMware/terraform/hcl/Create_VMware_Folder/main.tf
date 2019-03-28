
provider "vsphere" {
  version              = "~> 1.3"
  allow_unverified_ssl = "${var.allow_selfsigned_cert}"
}

################## Resources ###############################

# Create VM Server
module "create-vmware-folder" {
  source = "git::http://9.180.210.11/root/CAM2102.git//modules/create-vmware-folder"

  ####### Input
  datacenter        = "${var.datacenter}"
  folder            = "${var.folder}"
}
