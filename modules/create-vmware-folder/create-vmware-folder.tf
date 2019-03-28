
# Create vSphere Folder
resource "vsphere_folder" "folder_vm_1" {
  path          = "${var.folder}"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
  type          = "vm"
}

resource "null_resource" "folder-create_done" {
  depends_on = ["vsphere_folder.folder_vm_1"]

  provisioner "local-exec" {
    command = "echo 'Folder create done for ${var.folder}.'"
  }
}
