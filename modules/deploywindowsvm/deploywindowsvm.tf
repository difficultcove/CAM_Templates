################## Resources ###############################

#
# Create vSphere folder for the Virtual Machine
#
resource "vsphere_folder" "folder_vm_1" {
  count         = "${var.create_vm_folder}"
  path          = "${var.folder}"
  datacenter_id = "${data.vsphere_datacenter.datacenter.id}"
  type          = "vm"
}

#
# Create VM with single vnic on a network label by cloning
#
# Create VM Server
resource "vsphere_virtual_machine" "vm_1" {
  depends_on        = ["vsphere_folder.folder_vm_1"]
  name              = "${var.name}"
  folder            = "${var.folder}"
  num_cpus          = "${var.vcpu}"
  memory            = "${var.memory}"
  resource_pool_id  = "${data.vsphere_resource_pool.pool.id}"
  datastore_cluster_id      = "${data.vsphere_datastore_cluster.datastore_cluster.id}"
  guest_id          = "${data.vsphere_virtual_machine.template.guest_id}"
  scsi_type         = "${data.vsphere_virtual_machine.template.scsi_type}"
  num_cores_per_socket = 1
  cpu_hot_add_enabled  = true
  cpu_hot_remove_enabled = true
  memory_hot_add_enabled = true

  network_interface {
      network_id    = "${data.vsphere_network.network.id}"
  }

  # This section should prevent terraform from rebuilding a VM only on the same datastore that it was created on
#  lifecycle {
#    ignore_changes = [
#      "datastore_id",
#      "disk",
#    ]
#  }

  disk {
#    name              = "${var.name}.vmdk"
    label             = "${var.name}.vmdk"
    size              = "${var.rootdisksize}"
    thin_provisioned  = "${data.vsphere_virtual_machine.template.disks.0.thin_provisioned}"
  }

  clone {
    template_uuid = "${data.vsphere_virtual_machine.template.id}"
    timeout = "90"
    customize {
      ipv4_gateway = "${cidrhost("${var.ipv4_subnet}", "1")}"
      windows_options {
				computer_name 				= "${var.name}"
				admin_password 				= "${var.admin_password}"
#				time_zone							= 85
#				organization_name 		= "IBM"
#        workgroup             = "Workgroup"
#        product_key           = "${var.product_key}"
        #				join_domain 					= "${var.domain_name}"
        #				domain_admin_user 		= "${var.domainjoin_user}"
        #				domain_admin_password = "${var.domainjoin_password}"
      }
      network_interface {
        ipv4_address = "${cidrhost("${var.ipv4_subnet}", "${var.ipv4_subnet_index}")}"
        ipv4_netmask = "${element("${split("/","${var.ipv4_subnet}")}",1)}"
      }

    }
  }

}
resource "null_resource" "vm-create_done" {
  depends_on = ["vsphere_virtual_machine.vm_1"]

  provisioner "local-exec" {
    command = "echo 'VM create done for ${var.name}.'"
  }
}
