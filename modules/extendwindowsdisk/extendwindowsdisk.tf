resource "null_resource" "install_VM_dependsOn" {
  provisioner "local-exec" {
    command = "echo The dependsOn output for Single Node is ${var.dependsOn}"
  }
}

resource "null_resource" "single_vm_install" {
  depends_on = ["vsphere_virtual_machine.vm_1"]
  connection {
    type     = "winrm"
    user     = "Administrator"
    password = "${var.admin_password}"
    host     = "${cidrhost("${var.ipv4_subnet}","${var.ipv4_subnet_index}")}"
    bastion_host        = "${var.bastion_host}"
    bastion_user        = "${var.bastion_user}"
    bastion_private_key = "${ length(var.bastion_private_key) > 0 ? base64decode(var.bastion_private_key) : var.bastion_private_key}"
    bastion_port        = "${var.bastion_port}"
    bastion_host_key    = "${var.bastion_host_key}"
    bastion_password    = "${var.bastion_password}"
    insecure            = true
  }

provisioner "file" {
    content = <<EOF
  @echo off
  echo Starting Windows Config Script

  echo Extending Windows Root disk
  echo select disk 0 > C:\extendcmds
  echo select volume 1 >> C:\extendcmds
  echo extend >> C:\extendcmds
  diskpart /s C:\extendcmds

  echo End Windows config
  EOF
    destination = "c:\\config.cmd"
  }

# Execute the script remotely
# Execute the script remotely
  provisioner "remote-exec" {
    inline = [
			"c:\\config.cmd >> C:\\installation.log"
    ]
  }
}
resource "null_resource" "extendwindowsdisk_done" {
  depends_on = ["null_resource.extendlwindowsdisk"]

  provisioner "local-exec" {
    command = "echo Root disk extended "
  }
}
