
provider "vsphere" {
  version              = "~> 1.3"
  allow_unverified_ssl = "${var.allow_selfsigned_cert}"
}

################## Resources ###############################

# Create VM Server
module "create-vmware-folder" {
  source = "github.com/difficultcove/CAM_Templates/modules/create-vmware-folder"

  ####### Input
  datacenter        = "${var.datacenter}"
  folder            = "${var.folder}"
}
