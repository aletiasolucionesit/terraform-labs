# instance the provider
provider "libvirt" {
  uri = "qemu:///system"
}


# We fetch the latest ubuntu release image from their mirrors

resource "libvirt_network" "network"{
	name = "${var.purpose}-tf"
    mode = "nat"
    domain = "${var.purpose}.${var.base_domain}"
    addresses = ["${var.base_ip}.0/24"]
    dhcp{
		enabled = true
	}
	dns{
		enabled = true
		local_only = false
	}
}

resource "libvirt_volume" "os_image" {
  name = "os_image_${var.purpose}"
  source = var.image_id
  pool = var.libvirt_pool
}

resource "libvirt_volume" "volume-qcow2" {
  name = "${var.purpose}-tf-${count.index+1}.qcow2"
  base_volume_id = libvirt_volume.os_image.id
  count = var.machine_count
  pool = var.libvirt_pool
}

data "template_file" "user_data" {
  template = "${file("${path.module}/cloud_init.cfg")}"
}

data "template_file" "network_config" {
  template = "${file("${path.module}/network_config.cfg")}"
}

# for more info about paramater check this out
# https://github.com/dmacvicar/terraform-provider-libvirt/blob/master/website/docs/r/cloudinit.html.markdown
# Use CloudInit to add our ssh-key to the instance
# you can add also meta_data field
resource "libvirt_cloudinit_disk" "commoninit" {
  name           = "commoninit.iso"
  user_data      = data.template_file.user_data.rendered
  network_config = data.template_file.network_config.rendered
}

# Create the machine
resource "libvirt_domain" "domain-machine" {
  count = var.machine_count
  name   = "${var.purpose}-tf-${count.index+1}"
  memory = var.memory
  vcpu   = var.vcpu

  cloudinit = libvirt_cloudinit_disk.commoninit.id

  network_interface {
    network_name = libvirt_network.network.name
    hostname       = "node-${count.index+1}.${var.purpose}.${var.base_domain}"
    addresses      = ["${var.base_ip}.2${count.index+1}"]
    mac            = "AA:BB:CC:11:22:2${count.index+1}"
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
    volume_id = libvirt_volume.volume-qcow2.*.id[count.index]
  }

  graphics {
    type        = "spice"
    listen_type = "address"
    autoport    = true
  }
}

# IPs: use wait_for_lease true or after creation use terraform refresh and terraform show for the ips of domain

