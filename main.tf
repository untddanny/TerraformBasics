#vpc
resource "aws_vpc" "main" {
    cidr_block = "10.0.0.0/16"
    tags = {
    Name = "MainVPC"
  }
}

#subnet
resource "aws_subnet" "main" {
    vpc_id = aws_vpc.main.id
    cidr_block              = "10.0.1.0/24"
    availability_zone       = "us-east-1a"
    tags = {
    Name = "MainSubnet"
  }
}

# Subnet in us-east-1b
resource "aws_subnet" "secondary" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true
  tags = {
    Name = "SecondarySubnet"
  }
}


#ec2 instance

resource "aws_instance" "main" {
    ami = "ami-0453ec754f44f9a4a"
    instance_type = "t2.micro"
    subnet_id = aws_subnet.main.id
    tags = {
    Name = "myec2"
  }
  
}

#s3

# S3 Bucket with Folder
resource "aws_s3_bucket" "example" {
  bucket = "example-bucket-terraform-qqqqqqqqqqqq"  
  tags = {
    Name = "ExampleBucket"
  }
}

resource "aws_s3_object" "folder" {
    bucket = "awsaws_s3_bucket.example.id"
    key    = "folder/"
    depends_on = [aws_s3_bucket.example]

}

#rds
# DB Subnet Group
resource "aws_db_subnet_group" "main" {
  name       = "main-db-subnet-group"
  subnet_ids = [aws_subnet.main.id, aws_subnet.secondary.id]  # Include both subnets
  tags = {
    Name = "MainDBSubnetGroup"
  }
}
resource "aws_db_instance" "default" {
  allocated_storage    = 10
  db_name              = "mydb"
  engine               = "mysql"
  engine_version       = "8.0"
  instance_class       = "db.t3.micro"
  username             = "admin"
  password             = "admin123"
  parameter_group_name = "default.mysql8.0"
  db_subnet_group_name = aws_db_subnet_group.main.name
  skip_final_snapshot  = true
  tags = {
    Name = "ExampleRDS"
  }
}

#iam

resource "aws_iam_role" "test_role" {
  name = "test_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })

  tags = {
    tag-key = "tag-value"
  }
}

#iam user
resource "aws_iam_user" "lb" {
  name = "newuser"

  tags = {
    tag-key = "tag-value"
  }
}

resource "aws_iam_access_key" "lb" {
  user = aws_iam_user.lb.name
}

data "aws_iam_policy_document" "lb_ro" {
  statement {
    effect    = "Allow"
    actions   = ["ec2:*", "s3:*", "rds:*", "vpc:*"]
    resources = ["*"]
  }
}

resource "aws_iam_user_policy" "lb_ro" {
  name   = "test"
  user   = aws_iam_user.lb.name
  policy = data.aws_iam_policy_document.lb_ro.json
}


resource "local_file" "empty_file" {
  content  = ""
  filename = "/Users/nabeel/Devops/Terraform/Multiple resources/emptyfile.txt"
}