variable "image_id" {
  type = "string"
  default = "https://cloud.centos.org/centos/8/x86_64/images/CentOS-8-GenericCloud-8.1.1911-20200113.3.x86_64.qcow2"
  # default = "/var/lib/libvirt/images/CentOS-8-GenericCloud-8.1.1911-20200113.3.x86_64.qcow2"
}

variable "purpose" {
  type = "string"
  default = "test"
}

variable "machine_count" {
  type = "string"
  default = "1"
}

variable "libvirt_pool"{
  type = "string"
  default = "vms"
}

variable "memory"{
  type = "string"
  default = "2048"
}

variable "vcpu"{
  type = "string"
  default = "1"
}

variable "base_domain"{
  type = "string"
  default = "test"
}

variable "base_ip"{
  type = "string"
  default = "192.168.100"
}
