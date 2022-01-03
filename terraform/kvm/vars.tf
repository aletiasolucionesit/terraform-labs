variable "image_id" {
  type = string
  #default = "https://cloud.centos.org/centos/8/x86_64/images/CentOS-8-GenericCloud-8.4.2105-20210603.0.x86_64.qcow2"
  #default = "/var/lib/libvirt/images/CentOS-8-GenericCloud-8.4.2105-20210603.0.x86_64.qcow2"
  default = "/var/lib/libvirt/images/CentOS-7-x86_64-GenericCloud.qcow2"
}

variable "purpose" {
  type = string
  default = "ocp3"
}

variable "machine_count" {
  type = string
  default = "4"
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

variable "machinesubhost"{
  type = number
  default = 2
}

variable "memory"{
  type = number
  default = 6192
}

variable "vcpu"{
  type = number
  default = 2
}

variable "base_domain"{
  type = string
  default = "dummy"
}

variable "base_ip"{
  type = string
  default = "192.168.27"
}
