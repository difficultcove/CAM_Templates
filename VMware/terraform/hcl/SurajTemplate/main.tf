##################### Variables for Version 3.0.0 for FMS PROD ONLY###############################

variable "name" {
	description = "Name of the Virtual Machine"
}

variable "datacenter" {
	description = "Target vSphere datacenter for Virtual Machine creation"
}

variable "vcpu" {
	description = "Number of Virtual CPU for the Virtual Machine"
	default = 4
}

variable "memory" {
	description = "Memory for Virtual Machine in MBs"
	default = 128
}

variable "cluster" {
	description = "Target vSphere Cluster to host the Virtual Machine"
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


variable "network_label_2" {
	description = "vSphere Port Group or Network label for Virtual Machine's 2nd vNIC" 
}

variable "ipv4_address_2" {
	description = "IPv4 address for 2nd vNIC configuration"
}

variable "ipv4_gateway_2" {
	description = "IPv4 gateway for 2nd vNIC configuration"
}

variable "ipv4_prefix_length_2" {
	description = "IPv4 Prefix length for 2nd vNIC configuration"
}


variable "storage" {
	description = "Data store or storage cluster name for target VMs disks"
}


variable "vm_template" {
	description = "Source VM or Template label for cloning"
}

variable "ssh_user" {
	description = "User to login to the vm"
}


variable "backup_disk_size"
{

description = "Backup   disk size used for BigFix"
}


variable "bf_disk_size"
{
description = "Bigfix application disk size"
}

variable "data_disk_size"
{
description = "Data   disk size for Application"
}

variable "sql_disk_size"
{
description = "Backup   disk size for SQL db"
}
variable "log_disk_size"
{
description = "Backup   disk size for Log"
}


variable "temp_disk_size"
{
description = "Backup   disk size for Temp"
}


variable "ssh_user_password" {
	description = "Password to login to the vm"
}

variable "allow_selfsigned_cert" {
    description = "Communication with vsphere server with self signed certificate"
    default = true
}

variable "dns_suffixes" {
  description = "Name resolution suffixes for the virtual network adapter"

}

variable "user_public_key" {
description = "User Key to login to the vm"
}

variable "cms_chef_server_url"
{
	description = "Chef Server to use for CMS"
    default="false"
    }





        
############### Optinal settings in provider ##########
provider "vsphere" {
    version = "1.1"
    allow_unverified_ssl = "${var.allow_selfsigned_cert}"
}
 
data "vsphere_datacenter" "datacenter" {
  name = "${var.datacenter}"
}

data "vsphere_virtual_machine" "template" {
  name          = "${var.vm_template}"
  datacenter_id = "${data.vsphere_datacenter.datacenter.id}"
}

data "vsphere_datastore" "datastore" {
  name          = "${var.storage}"
  datacenter_id = "${data.vsphere_datacenter.datacenter.id}"
}



data "vsphere_resource_pool" "pool" {
  name          = "${var.cluster}"
  datacenter_id = "${data.vsphere_datacenter.datacenter.id}"
}

data "vsphere_network" "network" {
  name          = "${var.network_label}"
  datacenter_id = "${data.vsphere_datacenter.datacenter.id}"
}

data "vsphere_network" "imz_network" {
  name          = "${var.network_label_2}"
  datacenter_id = "${data.vsphere_datacenter.datacenter.id}"
}


################## Resources ###############################

#
# Create VM with single vnic on a network label by cloning 
#
resource "vsphere_virtual_machine" "vm_1" {
  name   = "${var.name}"
  resource_pool_id = "${data.vsphere_resource_pool.pool.id}"
  datastore_id     = "${data.vsphere_datastore.datastore.id}"
  num_cpus   = "${var.vcpu}"
  memory = "${var.memory*1024}"
  guest_id = "${data.vsphere_virtual_machine.template.guest_id}"

  network_interface {
      network_id = "${data.vsphere_network.network.id}"
  }
  
  network_interface {
      network_id = "${data.vsphere_network.imz_network.id}"
  }
 

  disk {
    name = "${var.name}.vmdk"
    size = "${data.vsphere_virtual_machine.template.disks.0.size}"
    eagerly_scrub    = "${data.vsphere_virtual_machine.template.disks.0.eagerly_scrub}"
    thin_provisioned = "${data.vsphere_virtual_machine.template.disks.0.thin_provisioned}"
  }
 
 scsi_type = "${data.vsphere_virtual_machine.template.scsi_type}"
        
 
 disk {
  	## THis is to extend the root vg - sdb - Set the size to 112
  	name = "${var.name}.1.vmdk"
    size = 120
    unit_number = 1
    datastore_id = "${data.vsphere_datastore.datastore.id}"
    
	}
  
  disk {
  ## This will be sdc or D drive
  	name = "${var.name}.2.vmdk"
    size = "${var.backup_disk_size}"
    unit_number = 2
    datastore_id = "${data.vsphere_datastore.datastore.id}"
    disk_mode = "independent_persistent"
	}
    
 disk {
 	## This will be sdd or E Drive
  	name = "${var.name}.3.vmdk"
    size = "${var.bf_disk_size}"
    unit_number = 3
    datastore_id = "${data.vsphere_datastore.datastore.id}"
    disk_mode = "independent_persistent"
	}
 
 disk {
 	## This will be sdd
  	name = "${var.name}.4.vmdk"
    size = "${var.data_disk_size}"
    unit_number = 4
    datastore_id = "${data.vsphere_datastore.datastore.id}"
    disk_mode = "independent_persistent"
	}
 
 
 disk {
 	## This will be sdd
  	name = "${var.name}.5.vmdk"
    size = "${var.sql_disk_size}"
    unit_number = 5
    datastore_id = "${data.vsphere_datastore.datastore.id}"
    disk_mode = "independent_persistent"
	}
        
 disk {
 	## This will be sdd
  	name = "${var.name}.6.vmdk"
    size = "${var.log_disk_size}"
    unit_number = 6
    datastore_id = "${data.vsphere_datastore.datastore.id}"
    disk_mode = "independent_persistent"
	}
	
	 disk {
 	## This will be sdd
  	name = "${var.name}.7.vmdk"
    size = "${var.temp_disk_size}"
    unit_number = 7
    datastore_id = "${data.vsphere_datastore.datastore.id}"
    disk_mode = "independent_persistent"
	}        
      # Specify the ssh connection for windows
  connection {
  	type = "ssh"
    user        = "Administrator"
    password    = "${var.ssh_user_password}" 
    host       =  "${var.ipv4_address}"
    
  }   
 
    
  clone {
    template_uuid = "${data.vsphere_virtual_machine.template.id}"

    customize {
    
      timeout = "120"
      windows_options
      {

        computer_name = "${var.name}"
        admin_password = "${var.ssh_user_password}"

      }
    

      network_interface {
        ipv4_address = "${var.ipv4_address}"
        ipv4_netmask = "${var.ipv4_prefix_length}"
      }


	  network_interface {
       ipv4_address= "${var.ipv4_address_2}"
       ipv4_netmask = "${var.ipv4_prefix_length_2}"
        
      }
     
      
       ipv4_gateway = "${var.ipv4_gateway}"
      
      
      
       dns_server_list     = ["169.55.254.73","169.55.254.90"]
       dns_suffix_list     = [" imzcloud.ibmammsap.local","ibmammsap.local","prdcloud.fms.ibmcloud.com"]
      
      
      
    
    }
    
   
  }
}

output "ipv4_address" {
  value = "${var.ipv4_address}"
}
output "disk_name" {
  value = "${vsphere_virtual_machine.vm_1.disk.name}"
}