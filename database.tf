# 1. Agrupar las subnets privadas para RDS
resource "aws_db_subnet_group" "main" {
  name       = "${var.project_name}-db-subnet-group"
  subnet_ids = [aws_subnet.private_1.id, aws_subnet.private_2.id]
  tags = { Name = "${var.project_name}-db-subnet-group" }
}

# 2. Instancia RDS MySQL Multi-AZ 
resource "aws_db_instance" "mysql" {
  allocated_storage      = 20
  db_name                = "tiendatechdb"
  engine                 = "mysql"
  engine_version         = "8.0" # O la version que requiera la app
  instance_class         = "db.t3.micro" # Capa gratuita elegible
  username               = "admin"
  password               = var.db_password
  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  
  multi_az               = true # !!! CLAVE PARA ALTA DISPONIBILIDAD !!! 
  skip_final_snapshot    = true # Para destrucción rápida en laboratorios

  tags = { Name = "${var.project_name}-mysql" }
}