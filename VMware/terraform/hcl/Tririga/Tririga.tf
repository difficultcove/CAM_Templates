#################################################################
# Terraform template that will deploy an VM with MongoDB only
#
# Version: 2.1.5
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Licensed Materials - Property of IBM
#
# ©Copyright IBM Corp. 2017.
#
#################################################################

###########################################################
# Define the vsphere provider
#########################################################
provider "vsphere" {
  allow_unverified_ssl = true
}

#########################################################
# Define the variables
#########################################################
variable "name" {
  description = "Name of the Virtual Machine"
  default     = ""
}

variable "folder" {
  description = "Target vSphere folder for Virtual Machine"
  default     = ""
}

variable "datacenter" {
  description = "Target vSphere datacenter for Virtual Machine creation"
  default     = ""
}

variable "vcpu" {
  description = "Number of Virtual CPU for the Virtual Machine"
  default     = 1
}

variable "rootdisksize" {
  description = "The Size of the root disk"
  default     = 16
}

variable "memory" {
  description = "Memory for Virtual Machine in GBs"
  default     = 1
}

variable "cluster" {
  description = "Target vSphere Cluster to host the Virtual Machine"
  default     = ""
}

variable "dns_suffixes" {
  description = "Name resolution suffixes for the virtual network adapter"
  type        = "list"
  default     = []
}

variable "dns_servers" {
  description = "DNS servers for the virtual network adapter"
  type        = "list"
  default     = []
}

variable "network_label" {
  description = "vSphere Port Group or Network label for Virtual Machine's vNIC"
}

variable "ipv4_address" {
  description = "IPv4 address for vNIC configuration"
}

variable "ipv4_gateway" {
  description = "IPv4 gateway for vNIC configuration"
}

variable "ipv4_prefix_length" {
  description = "IPv4 Prefix length for vNIC configuration"
}

variable "storage" {
  description = "Data store or storage cluster name for target VMs disks"
  default     = ""
}

variable "vm_template" {
  description = "Source VM or Template label for cloning"
}

variable "ssh_user" {
  description = "The user for ssh connection, which is default in template"
  default     = "root"
}

variable "ssh_user_password" {
  description = "The user password for ssh connection, which is default in template"
}

#variable "camc_private_ssh_key" {
#  description = "The base64 encoded private key for ssh connection"
#}

variable "user_public_key" {
  description = "User-provided public SSH key used to connect to the virtual machine"
  default     = "None"
}

variable "smb_share" {
  description = "Windows or SMB file server share"
  default     = "None"
}

variable "smb_user" {
  description = "User with access to SMB Share"
  default     = "None"
}

variable "smb_pwd" {
  description = "Base 64 encoded SMB user password"
  default     = "None"
}
##############################################################
# Create Virtual Machine and install Tririga
##############################################################
resource "vsphere_virtual_machine" "tririga_vm" {
  name         = "${var.name}"
  folder       = "${var.folder}"
  datacenter   = "${var.datacenter}"
  vcpu         = "${var.vcpu}"
  memory       = "${var.memory * 1024}"
  cluster      = "${var.cluster}"
  dns_suffixes = "${var.dns_suffixes}"
  dns_servers  = "${var.dns_servers}"
  network_interface {
    label              = "${var.network_label}"
    ipv4_gateway       = "${var.ipv4_gateway}"
    ipv4_address       = "${var.ipv4_address}"
    ipv4_prefix_length = "${var.ipv4_prefix_length}"
  }

  disk {
    datastore = "${var.storage}"
    type      = "thin"
    template  = "${var.vm_template}"
  }
  disk {
    name      = "${var.name}-2"
    datastore = "${var.storage}"
    type      = "thin"
    size      = "${var.rootdisksize}"
  }

  # Specify the ssh connection
  connection {
    user        = "${var.ssh_user}"
    password    = "${var.ssh_user_password}"
#    private_key = "${base64decode(var.camc_private_ssh_key)}"
    host        = "${self.network_interface.0.ipv4_address}"
  }

  provisioner "file" {
    content = <<EOF
#!/bin/bash

LOGFILE="/var/log/addkey.log"

user_public_key=$1

mkdir -p .ssh
if [ ! -f .ssh/authorized_keys ] ; then
    touch .ssh/authorized_keys                                    >> $LOGFILE 2>&1 || { echo "---Failed to create authorized_keys---" | tee -a $LOGFILE; exit 1; }
    chmod 400 .ssh/authorized_keys                                >> $LOGFILE 2>&1 || { echo "---Failed to change permission of authorized_keys---" | tee -a $LOGFILE; exit 1; }
fi

if [ "$user_public_key" != "None" ] ; then
    echo "---start adding user_public_key----" | tee -a $LOGFILE 2>&1

    chmod 600 .ssh/authorized_keys                                >> $LOGFILE 2>&1 || { echo "---Failed to change permission of authorized_keys---" | tee -a $LOGFILE; exit 1; }
    echo "$user_public_key" | tee -a $HOME/.ssh/authorized_keys   >> $LOGFILE 2>&1 || { echo "---Failed to add user_public_key---" | tee -a $LOGFILE; exit 1; }
    chmod 400 .ssh/authorized_keys                                >> $LOGFILE 2>&1 || { echo "---Failed to change permission of authorized_keys---" | tee -a $LOGFILE; exit 1; }

    echo "---finish adding user_public_key----" | tee -a $LOGFILE 2>&1
fi

EOF
    destination = "/tmp/addkey.sh"
  }

  provisioner "file" {
    content = <<EOF
#!/bin/bash

set -o errexit
set -o nounset
set -o pipefail

LOGFILE="/var/log/install_tririga.log"
echo "Starting Install" > $LOGFILE
echo "Input Params" >> $LOGFILE
echo $@ >> $LOGFILE
smbshare=$1
smbuser=$2
smbpwd=$(echo $3 | base64 -d )
echo "SMB Share=$smbshare SMBUser=$smbuser SMBPwd=$smbpwd" >> $LOGFILE

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

#mount File share
echo "Mounting fileshare" >> $LOGFILE
mkdir /software
mount -t cifs -o user=$smbuser,password=$smbpwd $smbshare /software
mount >> $LOGFILE

#extend root disks
echo "Extending root disk" >> $LOGFILE
echo -e "o\nn\np\n1\n\n\nw\n" | fdisk /dev/sdb | tee -a $LOGFILE 2>&1
vgextend rhel /dev/sdb1 | tee -a $LOGFILE 2>&1
lvresize -r -l+100%FREE /dev/rhel/root | tee -a $LOGFILE 2>&1


#setup Repository
rhel7http=/etc/yum.repos.d/rhel7http.repo
cat <<EOT | tee -a $rhel7http >> $LOGFILE 2>&1 || { echo "---Failed to create linux repo---" | tee -a $LOGFILE; exit 1; }
[rhel73repo]
name=RHEL73 Repository
baseurl=http://9.180.210.120/RedHat/RHEL73/
gpgcheck=0
enabled=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-redhat-release
EOT
yum clean all | tee -a $LOGFILE 2>&1

#Install zip and unzip
echo "Installing Zip and Unzip" >> $LOGFILE
yum install -y zip unzip | tee -a $LOGFILE 2>&1

#Install DB2
echo "Installing DB2 Pre-reqs" >> $LOGFILE
yum install -y libstdc++.so.6 | tee -a $LOGFILE 2>&1
groupadd db2fsdm1 | tee -a $LOGFILE 2>&1
adduser -g db2fsdm1 db2sdfe1 | tee -a $LOGFILE 2>&1

mkdir /tmp/db2
cd /tmp/db2
tar -xf /software/Software/Windows/IBM/Tririga/DB2_AWSE_REST_Svr_11.1_Lnx_86-64.tar.gz  | tee -a $LOGFILE 2>&1
cat /tmp/db2/server_awse_o/db2/linuxamd64/samples/db2server.rsp | sed -e 's/LIC_AGREEMENT *= DECLINE/LIC_AGREEMENT = ACCEPT/' > /tmp/db2/db2custom.rsp | tee -a $LOGFILE 2>&1
/tmp/db2/server_awse_o/db2setup -r /tmp/db2/db2custom.rsp | tee -a $LOGFILE 2>&1

#install Tririga
echo "---start installing Tririga-----" | tee -a $LOGFILE 2>&1
echo "---Installing Tririga Database--" | tee -a $LOGFILE 2>&1
mkdir /tmp/Tririga
cd /tmp/Tririga
unzip /software/Software/Windows/IBM/Tririga/TRI_APPLICATION_UPGRADE_10.5.1.zip | tee -a $LOGFILE 2>&1
cd /tmp/Tririga/CNB65ML/Scripts
adduser tridata | tee -a $LOGFILE 2>&1
adduser -G db2iadm1 triinst | tee -a $LOGFILE 2>&1
adduser -G db2iadm1 db2fenc1 | tee -a $LOGFILE 2>&1
./db2createinst.sh triinst 50006 /opt/ibm/db2/V11.1 db2fenc1 | tee -a $LOGFILE 2>&1
sudo su triinst ./db2configinst.sh triinst 50006 /opt/ibm/db2/V11.1 | tee -a $LOGFILE 2>&1
sudo su - triinst /tmp/Tririga/CNB65ML/db2createdb.sh tririga triinst US /opt/ibm/db2/V11.1/ tridata | tee -a $LOGFILE 2>&1

echo "---Installing Tririga Application--" | tee -a $LOGFILE 2>&1
cd /tmp/Tririga
tar -xf /software/Software/Windows/IBM/Tririga/TRI_Apps_353_Portfl_1053_Linux.tar | tee -a $LOGFILE 2>&1



echo "---finish installing Tririga---" | tee -a $LOGFILE 2>&1

#if hash iptables 2>/dev/null; then
	#update firewall
#	iptables -I INPUT 1 -p tcp -m tcp --dport 27017 -m conntrack --ctstate NEW -j ACCEPT     >> $LOGFILE 2>&1 || { echo "---Failed to update firewall---" | tee -a $LOGFILE; exit 1; }
#fi

EOF
    destination = "/tmp/installation.sh"
  }

  # Execute the script remotely
  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/addkey.sh; bash /tmp/addkey.sh \"${var.user_public_key}\"",
      "chmod +x /tmp/installation.sh; bash /tmp/installation.sh ${var.smb_share} ${var.smb_user} ${var.smb_pwd}"
    ]
  }
}

#########################################################
# Output
#########################################################
output "The IP address of the VM with Tririga installed" {
    value = "${vsphere_virtual_machine.tririga_vm.network_interface.0.ipv4_address}"
}
