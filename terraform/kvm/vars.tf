variable "image_id" {
  type = string
  #default = "https://cloud.centos.org/centos/8/x86_64/images/CentOS-8-GenericCloud-8.4.2105-20210603.0.x86_64.qcow2"
  default = "/var/lib/libvirt/images/CentOS-8-GenericCloud-8.4.2105-20210603.0.x86_64.qcow2"
}

variable "purpose" {
  type = string
  default = "do400"
}

variable "machine_count" {
  type = string
  default = "1"
}

variable "libvirt_pool"{
  type = string
  default = "default"
}

variable "maindisk_size"{
  type = number
  #default = 21474836480
  default = 53687091200
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
  default = "workstation"
}

variable "machinesubhost"{
  type = number
  default = 2
}

variable "memory"{
  type = number
  default = 4096
}

variable "vcpu"{
  type = number
  default = 2
}

variable "base_domain"{
  type = string
  default = "example.com"
}

variable "base_ip"{
  type = string
  default = "192.168.100"
}
