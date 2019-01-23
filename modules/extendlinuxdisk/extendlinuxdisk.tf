resource "null_resource" "install_VM_dependsOn" {
  provisioner "local-exec" {
    command = "echo The dependsOn output for Single Node is ${var.dependsOn}"
  }
}

#
resource "null_resource" "extendlinuxdisk" {
  	depends_on = ["null_resource.install_VM_dependsOn"]
    connection {
      type     = "ssh"
      user     = "${var.ssh_user}"
      private_key         = "${base64decode(var.ssh_user_private_key)}"
      host                = "${cidrhost("${var.ipv4_subnet}", "${var.ipv4_subnet_index}")}"
      bastion_host        = "${var.bastion_host}"
      bastion_user        = "${var.bastion_user}"
      bastion_private_key = "${ length(var.bastion_private_key) > 0 ? base64decode(var.bastion_private_key) : var.bastion_private_key}"
      bastion_port        = "${var.bastion_port}"
      bastion_host_key    = "${var.bastion_host_key}"
      bastion_password    = "${var.bastion_password}"
    }


  provisioner "file" {
    content = <<EOF
#!/bin/bash

set -o errexit
set -o nounset
set -o pipefail

LOGFILE="/var/log/installation.log"

echo "Starting Install" > $LOGFILE

if [ -f /etc/centos-release ]
then
#extend Centos root disks
  echo "Extending Centos root disk" >> $LOGFILE
  echo -e "n\np\n3\n\n\nw\n" | fdisk /dev/sda || echo "ignore warning" >> $LOGFILE
  partprobe | tee -a $LOGFILE 2>&1
  partprobe # Added this in because sometimes the partprobe didn't finish before the next command
  vgextend centos /dev/sda3 | tee -a $LOGFILE 2>&1
  lvresize -r -l+100%FREE /dev/centos/root | tee -a $LOGFILE 2>&1
else
  if [ -f /etc/redhat-release ]
  then
  #extend RHEL root disks
    echo "Extending RHEL root disk" >> $LOGFILE
    echo -e "n\np\n3\n\n\nw\n" | fdisk /dev/sda || echo "ignore warning" >> $LOGFILE
    partprobe | tee -a $LOGFILE 2>&1
    vgextend rhel /dev/sda3 | tee -a $LOGFILE 2>&1
    lvresize -r -l+100%FREE /dev/rhel/root | tee -a $LOGFILE 2>&1
  else
    echo "Extending Ubuntoo root disk" >> $LOGFILE
    vgname=$(vgs -o vg_name --noheadings | awk '{print $1}')
    #The next line will create a partition /dev/sda3 using some freespace found on the VM template
    # followed by /dev/sda4 which should be the additional space at the end of the disk.
    # some VM templates may not be partitioned this way.
    echo -e "n\np\n3\n\n\nn\np\n\n\nw\n" | fdisk /dev/sda || echo "ignore warning" >> $LOGFILE
    partprobe | tee -a $LOGFILE 2>&1
    partprobe # Added this in because sometimes the partprobe didn't finish before the next command
    vgextend $vgname /dev/sda4 | tee -a $LOGFILE 2>&1
    lvresize -r -l+100%FREE /dev/$vgname/root | tee -a $LOGFILE 2>&1
  fi
fi
echo "---finish installing VM---" | tee -a $LOGFILE 2>&1
EOF

    destination = "/tmp/installation.sh"
  }

# Execute the script remotely
  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/installation.sh; bash /tmp/installation.sh"
    ]
  }
}
resource "null_resource" "extendlinuxdisk_done" {
  depends_on = ["extendlinuxdisk"]

  provisioner "local-exec" {
    command = "echo Root disk extended "
  }
}
