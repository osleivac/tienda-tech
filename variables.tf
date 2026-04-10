variable "aws_region" {
  description = "Región de AWS para el despliegue"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Nombre del proyecto"
  type        = string
  default     = "tienda-tech"
}

variable "vpc_cidr" {
  description = "CIDR para la VPC"
  type        = string
  default     = "10.0.0.0/16"
}

# Se recomienda pasar esta variable vía command line o archivo tfvars secreto
variable "db_password" {
  description = "Contraseña para la base de datos MySQL"
  type        = string
  sensitive   = true
}

variable "instance_type" {
  description = "Tipo de instancia EC2"
  type        = string
  default     = "t3.micro"
}