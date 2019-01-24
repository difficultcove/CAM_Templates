resource "null_resource" "install_VM_dependsOn" {
  provisioner "local-exec" {
    command = "echo The dependsOn output for Single Node is ${var.dependsOn}"
  }
}

resource "null_resource" "swinst-lin-mariadb" {
  depends_on = ["null_resource.install_VM_dependsOn"]
  connection {
    type                = "ssh"
    user                = "${var.ssh_user}"
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

LOGFILE="/var/log/install_mariadb.log"
echo "Starting Install" > $LOGFILE

retryInstall () {
  n=0
  max=5
  command=$1
  while [ $n -lt $max ]; do
    $command && break
    let n=n+1
    if [ $n -eq $max ]; then
      echo "---Exceed maximal number of retries---"
      exit 1
    fi
    sleep 15
  done
}
echo "---start installing mariaDB---" | tee -a $LOGFILE 2>&1
retryInstall "yum install -y mariadb mariadb-server" >> $LOGFILE 2>&1 || { echo "---Failed to install MariaDB---" | tee -a $LOGFILE; exit 1; }
systemctl start mariadb                              >> $LOGFILE 2>&1 || { echo "---Failed to start MariaDB---" | tee -a $LOGFILE; exit 1; }
systemctl enable mariadb                             >> $LOGFILE 2>&1 || { echo "---Failed to enable MariaDB---" | tee -a $LOGFILE; exit 1; }
echo "---finish installing mariaDB---" | tee -a $LOGFILE 2>&1

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

  resource "null_resource" "swinst-lin-mariadb_done" {
    depends_on = ["null_resource.swinst-lin-mariadb"]

    provisioner "local-exec" {
      command = "echo Maria DB installed on Linux host"
    }
  }
