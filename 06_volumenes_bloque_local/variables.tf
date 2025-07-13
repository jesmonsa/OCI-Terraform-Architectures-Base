# OCI Authentication and Configuration Variables

variable "tenancy_ocid" {
  description = "The OCID (Oracle Cloud Identifier) of the tenancy where resources will be created."
}

variable "user_ocid" {
  description = "The OCID of the user executing the OpenTofu scripts for provisioning resources."
}

variable "fingerprint" {
  description = "The fingerprint of the API signing key used for authenticating with OCI."
}

variable "private_key_path" {
  description = "The file path to the private key used for OCI API authentication."
}

variable "compartment_ocid" {
  description = "The OCID of the compartment where resources will be created. This is the parent compartment for the deployment."
}

variable "region" {
  description = "The region where OCI resources will be deployed, such as 'us-ashburn-1' or 'eu-frankfurt-1'."
}

# Availability Domain Configuration

variable "availability_domain_name" {
  description = "The name of the availability domain where resources will be deployed. Leave empty to default to the first available domain."
  default = ""
}

# Networking Variables

variable "vcn_cidr" {
  default     = "10.0.0.0/16"
  description = "CIDR block for the Virtual Cloud Network."
  validation {
    condition     = can(regex("^([0-9]{1,3}\\.){3}[0-9]{1,3}/[0-9]{1,2}$", var.vcn_cidr))
    error_message = "vcn_cidr must be a valid CIDR block."
  }  
}

variable "private_subnet_cidr" {
  default     = "10.0.1.0/24"
  description = "CIDR block for the private subnet hosting the web servers."
  validation {
    condition     = can(regex("^([0-9]{1,3}\\.){3}[0-9]{1,3}/[0-9]{1,2}$", var.private_subnet_cidr))
    error_message = "private_subnet_cidr must be a valid CIDR block."
  }
}

variable "lb_subnet_cidr" {
  default     = "10.0.2.0/24"
  description = "CIDR block for the load balancer subnet."
  validation {
    condition     = can(regex("^([0-9]{1,3}\\.){3}[0-9]{1,3}/[0-9]{1,2}$", var.lb_subnet_cidr))
    error_message = "lb_subnet_cidr must be a valid CIDR block."
  }
}

variable "bastion_subnet_cidr" {
  default     = "10.0.3.0/24"
  description = "CIDR block for the bastion host subnet."
  validation {
    condition     = can(regex("^([0-9]{1,3}\\.){3}[0-9]{1,3}/[0-9]{1,2}$", var.bastion_subnet_cidr))
    error_message = "bastion_subnet_cidr must be a valid CIDR block."
  }
}

variable "fss_subnet_cidr" {
  default = "10.0.4.0/24"
  description = "CIDR block for FSS subnet."
  validation {
    condition     = can(regex("^([0-9]{1,3}\\.){3}[0-9]{1,3}/[0-9]{1,2}$", var.fss_subnet_cidr))
    error_message = "fss_subnet_cidr must be a valid CIDR block."
  }
}

variable "bastion_allowed_ip" {
  description = "Trusted IP CIDR blocks for SSH access to the bastion host."
  default     = "0.0.0.0/0" # Replace with actual trusted CIDR
}

# Compute Variables

variable "ComputeCount" {
  default = 3
  description = "Number of compute instances to create."
  validation {
    condition     = var.ComputeCount > 0
    error_message = "ComputeCount must be greater than 0."
  }
}

variable "WebserverShape" {
  default = "VM.Standard.A1.Flex"
  description = "Shape for the compute instance."
  validation {
    condition     = contains(["VM.Standard.E3.Flex", "VM.Standard.E4.Flex", "VM.Standard.A1.Flex", "VM.Optimized3.Flex"], var.WebserverShape)
    error_message = "Shape must be one of the supported shapes: VM.Standard.E3.Flex, VM.Standard.E4.Flex, VM.Standard.A1.Flex, or VM.Optimized3.Flex."
  }
}

variable "WebserverFlexShapeOCPUS" {
  description = "The number of OCPUs (Oracle CPUs) to allocate for flexible compute shapes. This applies only to shapes that support customization."
  default = 1
}

variable "WebserverFlexShapeMemory" {
  description = "The amount of memory (in GB) to allocate for flexible compute shapes. This applies only to shapes that support customization."
  default = 2
}

variable "BastionShape" {
  default = "VM.Standard.A1.Flex"
  description = "Shape for the bastion instance."
  validation {
    condition     = contains(["VM.Standard.E3.Flex", "VM.Standard.E4.Flex", "VM.Standard.A1.Flex", "VM.Optimized3.Flex"], var.BastionShape)
    error_message = "Shape must be one of the supported shapes: VM.Standard.E3.Flex, VM.Standard.E4.Flex, VM.Standard.A1.Flex, or VM.Optimized3.Flex."
  }
}

variable "BastionFlexShapeOCPUS" {
  description = "The number of OCPUs (Oracle CPUs) to allocate for flexible bastion shapes. This applies only to shapes that support customization."
  default = 1
}

variable "BastionFlexShapeMemory" {
  description = "The amount of memory (in GB) to allocate for flexible bastion shapes. This applies only to shapes that support customization."
  default = 2
}

# Operating System Variables
variable "instance_os" {
  description = "The operating system for the compute instance, such as 'Ubuntu' or 'Canonical Ubuntu'."
  default = "Canonical Ubuntu"
}

variable "linux_os_version" {
  description = "The version of the operating system for the compute instance. For example, '22.04' for Ubuntu 22.04."
  default = "22.04"
}

variable "webserver_os_version" {
  description = "Ubuntu version tag para los webservers"
  type        = string
  default     = "22.04"
}

variable "webserver_shape" {
  description = "Shape OCI para los webservers"
  type        = string
  default     = "VM.Standard.A1.Flex"
}

variable "bastion_os_version" {
  description = "Ubuntu version tag para el bastion"
  type        = string
  default     = "22.04"
}

variable "bastion_shape" {
  description = "Shape OCI para el bastion"
  type        = string
  default     = "VM.Standard.A1.Flex"
}

# Security Configuration Variables
variable "webservice_ports" {
  type        = list(string)
  description = "A list of TCP ports to open for ingress traffic in the security list. Common ports include 80 (HTTP), 443 (HTTPS)."
  default     = [80, 443]
}

variable "ssh_ports" {
  type        = list(string)
  description = "List of ports to allow ingress traffic to the bastion host and webservers. Default is 22 for SSH."
  default     = [22]
}

# Load Balancer Variables

variable "lb_shape" {
  description = "Defines the shape of the load balancer. Use 'flexible' for dynamic scaling or specify fixed shapes like '10Mbps' or '100Mbps'."
  default     = "flexible"
}

variable "flex_lb_min_shape" {
  description = "Minimum bandwidth (in Mbps) for the flexible load balancer."
  default     = 10
}

variable "flex_lb_max_shape" {
  description = "Maximum bandwidth (in Mbps) for the flexible load balancer."
  default     = 100
}

# FSS Variables

variable "MountTargetIPAddress" {
  description = "Mount Target IP Address"
  default = "10.0.4.25"
}

# SSH Key Configuration

variable "ssh_private_key_filename" {
  type        = string
  default     = "id_rsa_enterprise"
  description = "Nombre del archivo de la clave privada SSH"
}

# Block Volume Variables

variable "volume_size_in_gbs" {
  description = "The size of the block volume in gigabytes. Adjust this value based on your application's storage requirements."
  default     = 100
  validation {
    condition     = var.volume_size_in_gbs > 0
    error_message = "Volume size must be greater than 0 GB."
  }
}

variable "vpus_per_gb" {
  description = "The performance level of the block volume. Accepted values: 0=Low Cost, 10=Balanced, 20=HigherPerformance, or 30=UltraHighPerformance."
  default     = 10
  validation {
    condition     = contains([0, 10, 20, 30], var.vpus_per_gb)
    error_message = "Volume performance must be one of the following values: 0=Low Cost, 10=Balanced, 20=HigherPerformance, or 30=UltraHighPerformance."
  }
}
