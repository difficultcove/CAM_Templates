output "dependsOn" { value = "${null_resource.vm-create_done.id}" description="Output Parameter when Module Complete"}
output "ipv4_address" {
	value = "${vsphere_virtual_machine.vm_1.ipv4_address}" 
	description="IP Address of VM"
}