variable "image_id" {
  type = string
  # default = "https://cloud.centos.org/centos/8/x86_64/images/CentOS-8-GenericCloud-8.3.2011-20201204.2.x86_64.qcow2"
  default = "/var/lib/libvirt/images/CentOS-8-GenericCloud-8.3.2011-20201204.2.x86_64.qcow2"
}

variable "purpose" {
  type = string
  default = "ceph"
}

variable "mon_count" {
  type = number
  default = 3
}

variable "osd_count" {
  type = number
  default = 3
}

variable "libvirt_pool"{
  type = string
  default = "default"
}

variable "maindisk_size"{
  type = number
  default = 21474836480
}

variable "secondarydisk_size"{
  type = number
  default = 53687091200
}

variable "secondary"{
  type = string
  default = "secondary"
}

variable "machinename"{
  type = string
  default = "node"
}

variable "monsubhost"{
  type = number
  default = 2
}

variable "osdsubhost"{
  type = number
  default = 3
}

variable "memory"{
  type = number
  default = 2048
}

variable "vcpu"{
  type = number
  default = 1
}

variable "mon_memory"{
  type = number
  default = 2048 
}

variable "mon_vcpu"{
  type = number
  default = 1
}

variable "osd_memory"{
  type = number
  default = 4096
}

variable "osd_vcpu"{
  type = number
  default = 1
}

variable "base_domain"{
  type = string
  default = "test"
}

variable "base_ip"{
  type = string
  default = "192.168.100"
}
