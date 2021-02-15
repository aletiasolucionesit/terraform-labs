terraform {
 required_version = ">= 0.13"
  required_providers {
    libvirt = {
      source  = "dmacvicar/libvirt"
      version = "0.6.3"
    }
  }
}
# instance the provider
provider "libvirt" {
  uri = "qemu:///system"
}


## Common
data "template_file" "user_data" {
  template = file("${path.module}/cloud_init.tpl")
}

data "template_file" "network_config" {
  template = file("${path.module}/network_config.tpl")
}

# for more info about paramater check this out
# https://github.com/dmacvicar/terraform-provider-libvirt/blob/master/website/docs/r/cloudinit.html.markdown
# Use CloudInit to add our ssh-key to the instance
# you can add also meta_data field
resource "libvirt_cloudinit_disk" "commoninit" {
  name           = format("commoninit-%s.iso",var.purpose)
  user_data      = data.template_file.user_data.rendered
  network_config = data.template_file.network_config.rendered
}


resource "libvirt_network" "network"{
    name = format("%s-tf",var.purpose)
    mode = "nat"
    domain = format("%s.%s",var.purpose,var.base_domain)
    addresses = [format("%s.0/24",var.base_ip)]
    dhcp{
		enabled = true
	}
	dns{
		enabled = true
		local_only = false
	}
}

resource "libvirt_volume" "os_image" {
  name = format("os_image_%s",var.purpose)
  source = var.image_id
  pool = var.libvirt_pool
}

resource "libvirt_volume" "adminvolume-qcow2" {
  name = format("%s-tf-admin.qcow2",var.purpose)
  base_volume_id = libvirt_volume.os_image.id
  pool = var.libvirt_pool
  size = var.maindisk_size
}

resource "libvirt_volume" "monvolume-qcow2" {
  name = format("%s-tf-mon-%s.qcow2",var.purpose,count.index+1)
  base_volume_id = libvirt_volume.os_image.id
  count = var.mon_count
  pool = var.libvirt_pool
  size = var.maindisk_size
}

resource "libvirt_volume" "osdvolume-qcow2" {
  name = format("%s-tf-osd-%s.qcow2",var.purpose,count.index+1)
  base_volume_id = libvirt_volume.os_image.id
  count = var.osd_count
  pool = var.libvirt_pool
  size = var.maindisk_size
}

resource "libvirt_volume" "secondary-qcow2"{
  name = format("%s-tf-%s-%s.qcow2",var.purpose,var.secondary,count.index+1)
  count = var.osd_count
  pool = var.libvirt_pool
  size = var.secondarydisk_size
}

# Create the machine
resource "libvirt_domain" "admin-machine" {
  name   = format("%s-admin-tf",var.purpose)
  memory = var.memory
  vcpu   = var.vcpu

  cloudinit = libvirt_cloudinit_disk.commoninit.id

  network_interface {
    network_name = libvirt_network.network.name
    hostname       = format("cephadmin.%s.%s",var.purpose,var.base_domain)
    addresses      = [format("%s.10",var.base_ip)]
    mac            = "AA:BB:CC:11:22:10"
    wait_for_lease = true
  }

  # IMPORTANT: this is a known bug on cloud images, since they expect a console
  # we need to pass it
  # https://bugs.launchpad.net/cloud-images/+bug/1573095
  console {
    type        = "pty"
    target_port = "0"
    target_type = "serial"
  }

  console {
    type        = "pty"
    target_type = "virtio"
    target_port = "1"
  }

  disk {
    volume_id = libvirt_volume.adminvolume-qcow2.id
  }

  graphics {
    type        = "spice"
    listen_type = "address"
    autoport    = true
  }
}

# IPs: use wait_for_lease true or after creation use terraform refresh and terraform show for the ips of domain

# Create the machine
resource "libvirt_domain" "mon-machine" {
  count = var.mon_count
  name   = format("%s-mon-tf-%s",var.purpose,count.index+1)
  memory = var.mon_memory
  vcpu   = var.mon_vcpu

  cloudinit = libvirt_cloudinit_disk.commoninit.id

  network_interface {
    network_name = libvirt_network.network.name
    hostname       = format("cephmon-%s.%s.%s",count.index+1,var.purpose,var.base_domain)
    addresses      = [format("%s.%s%s",var.base_ip,var.monsubhost,count.index+1)]
    mac            = format("AA:BB:CC:11:22:%s%s",var.monsubhost,count.index+1)
    wait_for_lease = true
  }

  # IMPORTANT: this is a known bug on cloud images, since they expect a console
  # we need to pass it
  # https://bugs.launchpad.net/cloud-images/+bug/1573095
  console {
    type        = "pty"
    target_port = "0"
    target_type = "serial"
  }

  console {
    type        = "pty"
    target_type = "virtio"
    target_port = "1"
  }

  disk {
    volume_id = libvirt_volume.monvolume-qcow2.*.id[count.index]
  }

  graphics {
    type        = "spice"
    listen_type = "address"
    autoport    = true
  }
}

# Create the machine
resource "libvirt_domain" "osd-machine" {
  count = var.osd_count
  name   = format("%s-osd-tf-%s",var.purpose,count.index+1)
  memory = var.memory
  vcpu   = var.vcpu

  cloudinit = libvirt_cloudinit_disk.commoninit.id

  network_interface {
    network_name = libvirt_network.network.name
    hostname       = format("cephosd-%s.%s.%s",count.index+1,var.purpose,var.base_domain)
    addresses      = [format("%s.%s%s",var.base_ip,var.osdsubhost,count.index+1)]
    mac            = format("AA:BB:CC:11:22:%s%s",var.osdsubhost,count.index+1)
    wait_for_lease = true
  }

  # IMPORTANT: this is a known bug on cloud images, since they expect a console
  # we need to pass it
  # https://bugs.launchpad.net/cloud-images/+bug/1573095
  console {
    type        = "pty"
    target_port = "0"
    target_type = "serial"
  }

  console {
    type        = "pty"
    target_type = "virtio"
    target_port = "1"
  }

  disk {
    volume_id = libvirt_volume.osdvolume-qcow2.*.id[count.index]
  }

  disk {
    volume_id = libvirt_volume.secondary-qcow2.*.id[count.index]
  }

  graphics {
    type        = "spice"
    listen_type = "address"
    autoport    = true
  }
}
