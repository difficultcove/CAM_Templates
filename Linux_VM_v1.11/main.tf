
provider "vsphere" {
  version              = "~> 1.3"
  allow_unverified_ssl = "${var.allow_selfsigned_cert}"
}

################## Resources ###############################

#
# Create vSphere folder for the Virtual Machine
#
#resource "vsphere_folder" "folder_vm_1" {
#  count         = "${var.create_vm_folder}"
#  path          = "${var.folder}"
#  datacenter_id = "${data.vsphere_datacenter.datacenter.id}"
#  type          = "vm"
#}

#
# Create VM with single vnic on a network label by cloning

# Create VM Server
module "deploylinuxvm" {
#  source = "git::http://9.180.210.11/root/deploylinuxvm.git"
# source = "git::http://9.180.210.11/root/CAM2102.git//modules/deploylinuxvm"
  source = "github.com/difficultcove/CAM_Templates/modules/deploylinuxvm"

  # VSphere
  allow_selfsigned_cert     = "${var.allow_selfsigned_cert}"
  create_vm_folder          = "${var.create_vm_folder}"
  folder                    = "${var.folder}"

  ####### input to Data Segment
  datacenter            = "${var.datacenter}"
  cluster               = "${var.cluster}"
  storage               = "${var.storage}"
  network_label         = "${var.network_label}"
  vm_template           = "${var.vm_template}"

  ####### input to Resource Segment
  name         = "${var.name}"
  vcpu         = "${var.vcpu}"
  memory       = "${var.memory}"
  rootdisksize = "${var.rootdisksize}"
  ipv4_subnet  = "${var.ipv4_subnet}"
  domain_name  = "${var.domain_name}"
  ipv4_subnet_index = "${var.ipv4_subnet_index}"

}

module "extendlinuxdisk" {
#  source = "git::http://9.180.210.11/root/extendlinuxdisk"
  source = "git::http://9.180.210.11/root/CAM2102.git//modules/config-linux-rootdisk"
#  source = "github.com/difficultcove/CAM_Templates/modules/extendlinuxdisk"

  ssh_user            = "${var.ssh_user}"
  ssh_password        = "${var.ssh_password}"
  ssh_user_private_key = "${var.ssh_user_private_key}"
  bastion_host        = "${var.bastion_host}"
  bastion_user        = "${var.bastion_user}"
  bastion_private_key = "${var.bastion_private_key}"
  bastion_port        = "${var.bastion_port}"
  bastion_host_key    = "${var.bastion_host_key}"
  bastion_password    = "${var.bastion_password}"
  ipv4_address        = "${module.deploylinuxvm.ipv4_address}"
  dependsOn           = "${module.deploylinuxvm.dependsOn}"

}
