provider "aws" {
  access_key = "access"
  secret_key = "secret"
  region     = "us-east-1"
}

resource "aws_internet_gateway" "gw1" {
  vpc_id = "${aws_vpc.first_terrafor.id}"

  tags = {
    Name = "IG_1"
  }
}

resource "aws_instance" "webserver" {
    ami = "ami-0565af6e282977273"
    subnet_id = "${aws_subnet.sub_1.id}"
    instance_type = "t2.micro"
    key_name = "chefrg"
    associate_public_ip_address = "true"
    vpc_security_group_ids = ["${aws_security_group.sg_1.id}"]
    provisioner "remote-exec" {
        inline = [
            "sudo git clone https://github.com/omkaramkalyan/new_ansible_terraform.git",
            "sudo apt-get update -y",
            "sudo apt-get install software-properties-common -y",
            "sudo apt-add-repository --yes --update ppa:ansible/ansible",
            "sudo apt-get install ansible -y",
            "ansible-playbook /home/ubuntu/new_ansible_terraform/tomcat8.yml"
            ]
    }
    connection {
        type     = "ssh"
        user     = "ubuntu"
        private_key = "${file("./chefrg.pem")}"
    }
  
}

resource "aws_vpc" "first_terrafor" {
    cidr_block = "10.0.0.0/16"
    tags = {
        Name = "first_terraform"
    }
}
resource "aws_subnet" "sub_1" {
  vpc_id     = "${aws_vpc.first_terrafor.id}"
  cidr_block = "10.0.0.0/24"

  tags = {
    Name = "sub_1"
  }
}

resource "aws_route_table" "vpc1_rt" {
  vpc_id     = "${aws_vpc.first_terrafor.id}"
  route = {
      cidr_block = "0.0.0.0/0"
      gateway_id = "${aws_internet_gateway.gw1.id}"
  }
  tags = {
      Name = "rt_1"
  }
}


resource "aws_route_table_association" "subass_1" {
    route_table_id = "${aws_route_table.vpc1_rt.id}"
    subnet_id = "${aws_subnet.sub_1.id}"
}


resource "aws_security_group" "sg_1" {
  vpc_id = "${aws_vpc.first_terrafor.id}"
  name = "sg_1"
  ingress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}