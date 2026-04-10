# 1. Security Group para el Load Balancer (SG-ALB) 
resource "aws_security_group" "alb_sg" {
  name        = "${var.project_name}-alb-sg"
  description = "Permite acceso HTTP y 3001 desde Internet"
  vpc_id      = aws_vpc.main.id

  # Inbound HTTP 80
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Inbound TCP 3001 (Backend) 
  ingress {
    from_port   = 3001
    to_port     = 3001
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Egress total
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# 2. Security Group para las instancias EC2 (SG-EC2)
resource "aws_security_group" "ec2_sg" {
  name        = "${var.project_name}-ec2-sg"
  description = "Permite trafico desde el ALB"
  vpc_id      = aws_vpc.main.id

  # Inbound Frontend (80) desde SG-ALB 
  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  # Inbound Backend (3001) desde SG-ALB 
  ingress {
    from_port       = 3001
    to_port         = 3001
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  # Opcional: SSH para administracion (solo si es necesario, mejor usar Systems Manager)
  # ingress { from_port = 22, to_port = 22, protocol = "tcp", cidr_blocks = ["TU_IP/32"] }

  # Egress total (necesario para NAT Gateway)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# 3. Security Group para RDS (SG-RDS)
resource "aws_security_group" "rds_sg" {
  name        = "${var.project_name}-rds-sg"
  description = "Permite acceso MySQL solo desde EC2"
  vpc_id      = aws_vpc.main.id

  # Inbound MySQL (3306) desde SG-EC2
  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.ec2_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}