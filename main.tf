module "vpc" {
  source               = "./modules/vpc"
  name_prefix          = "iti"
  vpc_cidr             = "10.42.0.0/16"
  azs                  = ["us-east-1a", "us-east-1b"]
  public_subnet_cidrs  = ["10.42.1.0/24", "10.42.2.0/24"]
  private_subnet_cidrs = ["10.42.3.0/24", "10.42.4.0/24"]
  create_nat_per_az    = true
  extra_tags           = { project = "test" }
}

module "frontend" {
  source           = "./modules/ec2"
  ami_owner        = ["amazon"]
  ami_name_filter  = ["amzn2-ami-hvm-*-x86_64-gp2"]
  ami_architecture = ["x86_64"]
  instance_type    = "t2.micro"
  instance_name    = "frontend"
  subnet_id        = module.vpc.public_subnet_ids[0]
  depends_on       = [module.vpc, module.backend]

  user_data = templatefile("./web_app/frontend/frontend.tpl", {
    backend_ip = module.backend.private_ip
    index_file = file("${path.module}/web_app/frontend/index.html")
  })

  inbound = { http = {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    cidr_blocks     = ["0.0.0.0/0"]
    security_groups = []
    }
  }

  outbound = { all = {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
    security_groups = []
  } }
  vpc_id = module.vpc.vpc_id
}

module "backend" {
  source           = "./modules/ec2"
  ami_owner        = ["amazon"]
  ami_name_filter  = ["amzn2-ami-hvm-*-x86_64-gp2"]
  ami_architecture = ["x86_64"]
  instance_type    = "t3.small"
  instance_name    = "backend"
  subnet_id        = module.vpc.private_subnet_ids[0]
  vpc_id           = module.vpc.vpc_id
  depends_on       = [module.vpc, aws_db_instance.database]

  user_data = templatefile("./web_app/backend/backend.tpl", {
    database_address = aws_db_instance.database.address
    app_file         = file("${path.module}/web_app/backend/app.py")
  })

  inbound = { frontend = {
    from_port       = 5000
    to_port         = 5000
    protocol        = "tcp"
    cidr_blocks     = ["10.42.1.0/24"]
    security_groups = []
    }
  }

  outbound = { all = {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
    security_groups = []
  } }
}


resource "aws_security_group" "database_sg" {
  name        = "database_sg"
  description = "Allow access database"
  vpc_id      = module.vpc.vpc_id

  tags = {
    Name = "database_sg"
  }

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["10.42.3.0/24"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_db_instance" "database" {
  allocated_storage      = 10
  db_name                = "mydb"
  engine                 = "mysql"
  engine_version         = "8.0.42"
  instance_class         = "db.t3.micro"
  username               = "root"
  password               = "root123456789"
  parameter_group_name   = "default.mysql8.0"
  skip_final_snapshot    = true
  vpc_security_group_ids = [aws_security_group.database_sg.id]
  db_subnet_group_name   = aws_db_subnet_group.default.name
}

resource "aws_db_subnet_group" "default" {
  name       = "database_subnet"
  subnet_ids = [module.vpc.private_subnet_ids[0], module.vpc.private_subnet_ids[1]]

  tags = {
    Name = "My DB subnet group"
  }
}