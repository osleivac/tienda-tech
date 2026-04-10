output "alb_dns_name" {
  description = "El nombre DNS del Application Load Balancer"
  value       = aws_lb.main.dns_name
}

output "rds_endpoint" {
  description = "Endpoint de la base de datos (para usar en User Data si es necesario)"
  value       = aws_db_instance.mysql.endpoint
}