##################################################################################
# VARIABLES
##################################################################################

variable "vsphere_user" {
  description = "vSphere administrator username"
  type        = string
  sensitive   = true
}

variable "vsphere_password" {
  description = "vSphere administrator password"
  type        = string
  sensitive   = true
}
variable "vsphere_server" {
  description = "vSphere IP Address or FQDN"
  type        = string
  sensitive   = true
}
variable "ssh-pub-key" {
  description = "Service Account SSH pub key"
  type        = string
  sensitive   = true
}

variable "service_account_username" {
  description = "Service account username"
  type        = string
  sensitive   = true
}

variable "service_account_password" {
  description = "Service account password"
  type        = string
  sensitive   = true
}

##################################################################################
# PROVIDERS
##################################################################################

provider "vsphere" {
  user = var.vsphere_user
  password = var.vsphere_password
  vsphere_server = var.vsphere_server

  # If you have a self-signed cert
  allow_unverified_ssl = true
}

##################################################################################
# DATA
##################################################################################

data "vsphere_datacenter" "dc" {
  name = "da-compute"
  #name = "DEVNET-DMZ"
}

data "vsphere_datastore" "datastore" {
  name          = "datastore-1"
  #name          = "hx-demo-ds1"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

data "vsphere_compute_cluster" "cluster" {
  name          = "cluster-1"
  #name          = "hx-demo"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

data "vsphere_network" "network" {
  name          = "management-vlan-200"
  #name          = "Management"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

data "vsphere_virtual_machine" "template" {
  name          = "CentOS-8-Minimal"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

resource "vsphere_virtual_machine" "vm1" {
  count            = 5
  name             = "apache-web-server-${count.index + 1}"
  resource_pool_id = "${data.vsphere_compute_cluster.cluster.resource_pool_id}"
  datastore_id     = "${data.vsphere_datastore.datastore.id}"
  firmware         = "${var.vsphere_vm_firmware}"

  num_cpus = 2
  memory   = 8096
  guest_id = "${data.vsphere_virtual_machine.template.guest_id}"

  scsi_type = "${data.vsphere_virtual_machine.template.scsi_type}"

  network_interface {
    network_id   = "${data.vsphere_network.network.id}"
    adapter_type = "${data.vsphere_virtual_machine.template.network_interface_types[0]}"
  }

  disk {
    label            = "disk0"
    size             = "${data.vsphere_virtual_machine.template.disks.0.size}"
    #eagerly_scrub    = "${data.vsphere_virtual_machine.template.disks.0.eagerly_scrub}"
    eagerly_scrub    = true
    thin_provisioned = "${data.vsphere_virtual_machine.template.disks.0.thin_provisioned}"
  }

  provisioner "remote-exec"  {
    inline = [
    "mkdir /home/delgadm/.ssh",
    "chmod 700 /home/delgadm/.ssh",
    "touch /home/delgadm/.ssh/authorized_keys",
    "chmod 600 /home/delgadm/.ssh/authorized_keys",
    "echo ${var.ssh-pub-key} >> /home/delgadm/.ssh/authorized_keys"
    ]

    connection {
    type     = "ssh"
    user     = "${var.service_account_username}"
    password = "${var.service_account_password}"
    host     = "10.200.0.${101 + count.index}"
  }

  }
  
  provisioner "local-exec" {
   command = "ansible-playbook -u delgadm -i apache-web-servers.txt main.yml --vault-password-file ./.vault_pass.txt"
   }

  clone {
    template_uuid = "${data.vsphere_virtual_machine.template.id}"

    customize {
      linux_options {
        host_name = "apache-webserver-${count.index + 1}"
        domain    = "test.internal"
      }

      network_interface {
        ipv4_address = "10.200.0.${101 + count.index}"
        ipv4_netmask = 24
      }

      ipv4_gateway = "10.200.0.254"

    }
  }

}
