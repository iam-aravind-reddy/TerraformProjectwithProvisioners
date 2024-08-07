provider "aws" {
  region = "us-east-1"
  access_key = "accesskey" # Your access Key
  secret_key = "secretkey" # Your secret key
}

resource "aws_key_pair" "mykeypair" {
  key_name = "mylocalkey"
  public_key = file("C:/Users/aravi/.ssh/id_rsa.pub") #Provide the local path for the public key
}

resource "aws_vpc" "newvpc" {
  cidr_block = var.cidr_block
}

resource "aws_subnet" "subnet1" {
  vpc_id = aws_vpc.newvpc.id
  cidr_block = var.cidr_subnet
  availability_zone = "us-east-1a"
  map_public_ip_on_launch = true
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.newvpc.id
}

resource "aws_route_table" "rt" {
    vpc_id = aws_vpc.newvpc.id

    route {
        cidr_block = var.cidr_rt
        gateway_id = aws_internet_gateway.igw.id
    }
}

resource "aws_route_table_association" "rta" {
  subnet_id = aws_subnet.subnet1.id
  route_table_id = aws_route_table.rt.id
}

resource "aws_security_group" "mysg" {
  name = "terraformsg"
  description = "Allowing SSH and HTTP traffic"
  vpc_id = aws_vpc.newvpc.id

  ingress {
    description = "SSH from VPC"
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = [ var.cidr_sg ]
  }
  ingress {
    description = "HTTP from VPC"
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = [ var.cidr_sg ]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = -1
    cidr_blocks = [ var.cidr_sg ]
  }
  tags = {
    name = "MYTERRAFORM_SG"
  }
}

resource "aws_instance" "instance" {
  ami = var.ami_id
  instance_type = var.instance_type
  key_name = aws_key_pair.mykeypair.key_name
  vpc_security_group_ids = [aws_security_group.mysg.id]
  subnet_id = aws_subnet.subnet1.id

  connection {
    type = "ssh"
    user = "ubuntu"
    private_key = file("C:/Users/aravi/.ssh/id_rsa") #Provide the local path for the private key
    host = self.public_ip
  }

  provisioner "file" {
    source = "app.py"
    destination = "/home/ubuntu/app.py"
  }

  provisioner "remote-exec" {

    inline = [ 
        "echo 'hello from remote execution provisioner'",
        "sudo apt update -y",
        "sudo apt-get install -y python3-pip",
        "cd /home/ubuntu",
        "sudo pip3 install flask",
        "sudo python3 app.py &" #to run this command in Background

     ]
    
  }

}

output "showipforconnection" {
  value = aws_instance.instance.public_ip
}
