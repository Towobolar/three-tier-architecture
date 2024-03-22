/***********************************************
*    web auto scaling launch configuration        *
************************************************/

resource "aws_launch_template" "three-tier-web-server-asg-lt" {
  name   = "web-server-asg"
  image_id      = "ami-0b9932f4918a00c4f"
  instance_type = "t2.micro"
  key_name      = aws_key_pair.three-tier-demo-key.id
}

/***********************************************
*     web auto scaling group                       *
************************************************/

resource "aws_autoscaling_group" "three-tier-web-server-asg" {
  desired_capacity    = 2
  max_size            = 4
  min_size            = 2
  vpc_zone_identifier = [aws_subnet.public-subnet-1.id, aws_subnet.public-subnet-2.id]

  launch_template {
    id      = aws_launch_template.three-tier-web-server-asg-lt.id
    version = "$Latest"
  }
}

/***********************************************
*              key pair                        *
************************************************/

resource "aws_key_pair" "three-tier-demo-key" {
  key_name   = "demo-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDuNDjqNLmFDfpAfLyk0xJI/mnsQJY7CBxcAqMOHnEUkRjdVtwDCGDadnG77iZjI0sNpVXqkZacSaxx684xGdy0tWihuixP81Kn+Zsgdwi+Mx4WjPfgT2s27lba2kZhJC0pEr5hzHEJWNwX1aOvQjGzIGr+898y6gwp/DK3cggFEQ/jNBCS76NYUFODQGpR4Wiw9cOo1B1TiGe0UW3H183+h/q1Fv3yGvFm6J0iQC83soT5hcskmuoDbstJF/y5jd7ghcQB+v67C3IWuC9oKnq+mte0oRg7+G7NnGsv1S3yBQobs8AuazOTPUmmQ/q/ThSClqwPUTd3ajfAd2sqz73+04ZDO+oZJsdYUUTl+rPzH3Qsn645iD+NJhK+G9Y8Kq6NWs2x+C2ikIPof8QIL/GfOfAk4TNi5DwCNTnhEJthPug6Zw7MhsySNjR5B5lin2Pa9iAmKLQ5XTNDvLs+gNqeEVWoBoYvM78CEh4A7+Q2Q224DvMeKrpgiVqUdI02Ht0= abbey@TOWOBOLA"
}

/***********************************************
*    app auto scaling launch configuration        *
************************************************/

resource "aws_launch_template" "three-tier-app-server-asg-lt" {
  name_prefix   = "app-server-asg"
  image_id      = "ami-0b9932f4918a00c4f"
  instance_type = "t2.micro"
  key_name      = aws_key_pair.three-tier-demo-key.id
}

/***********************************************
*     app auto scaling group                       *
************************************************/

resource "aws_autoscaling_group" "three-tier-app-server-asg" {
  desired_capacity    = 2
  max_size            = 4
  min_size            = 2
  vpc_zone_identifier = [aws_subnet.private-subnet-1.id, aws_subnet.private-subnet-2.id]

  launch_template {
    id      = aws_launch_template.three-tier-app-server-asg-lt.id
    version = "$Latest"
  }
}


/**************************************
*      Database subnet group          *
**************************************/

resource "aws_db_subnet_group" "database-sg" {
  name       = "main"
  subnet_ids = [aws_subnet.private-subnet-3.id, aws_subnet.private-subnet-4.id]

  tags = {
    Name = "My DB subnet group"
  }
}

/************************************
*     Database instance             *
************************************/

resource "aws_db_instance" "db-instance" {
  allocated_storage      = 20
  db_name                = "mydb"
  engine                 = "mysql"
  engine_version         = "5.7"
  instance_class         = "db.t3.micro"
  username               = "admin"
  password               = "password"
  parameter_group_name   = "default.mysql5.7"
  skip_final_snapshot    = true
  db_subnet_group_name   = aws_db_subnet_group.database-sg.id
  vpc_security_group_ids = [aws_security_group.db-sg.id]
}

/*******************************
*        bastion host         *
********************************/
resource "aws_instance" "bastion-host" {
  ami                         = "ami-0b9932f4918a00c4f"
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.public-subnet-1.id
  vpc_security_group_ids      = [aws_security_group.bastion-host-sg.id]
  key_name                    = aws_key_pair.three-tier-demo-key.id
  associate_public_ip_address = true

  tags = {
    Name = "bastion host instance"
  }
}

