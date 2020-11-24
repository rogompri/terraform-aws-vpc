variable "vpc_name" {
  description = "Nombre de la VPC"
  type        = string
  default     = ""
}

variable "vpc_cidr" {
  description = "Bloque CIDR de la VPC"
  type        = string
  default     = ""
}

variable "vpc_dns_support" {
  description = "Habilitar soporte DNS en la VPC"
  type        = bool
  default     = true
}

variable "vpc_dns_hostnames" {
  description = "Habilitar hostnames DNS en la VPC"
  type        = bool
  default     = true
}

variable "public_subnets" {
  description = "Bloques CIDR de las subredes publicas"
  type        = list(string)
  default     = []
}

variable "private_subnets" {
  description = "Bloques CIDR de las subredes privadas"
  type        = list(string)
  default     = []
}

variable "availability_zones" {
  description = "Zonas de disponibilidad para las subredes"
  type        = list(string)
  default     = []
}

variable "nat_gw" {
  description = "Crear NAT Gateways"
  type        = bool
  default     = false 
}
