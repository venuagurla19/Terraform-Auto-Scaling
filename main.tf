provider "aws" {
    region = "us-east-2"
}

variable "server_port" {
    description = "The port the server should use for HTTP requests"
    default     = 8080
    type = number

}

resource "aws_security_group" "terrasec" {
    name = "Terraform Security Group"
    description = "Allow HTTP and SSH from anywhere"
    vpc_id = data.aws_vpc.main.id# Specify the ID of our VPC here!
    
    ingress {
        from_port = var.server_port
        to_port = var.server_port
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
}


resource "aws_instance" "terra" {
    ami           = "ami-07b36ea9852e986ad"
    instance_type = "t2.micro"
    vpc_security_group_ids = [aws_security_group.terrasec.id]
    subnet_id = data.aws_subnet.default.id
    connection {
    type = "ssh"
}
}

resource "aws_launch_configuration" "auto" {
    image_id      = "ami-07b36ea9852e986ad"
    instance_type = "t2.micro"
    security_groups = [aws_security_group.terrasec.id]
    associate_public_ip_address=true
    user_data = <<-EOF
                #!/bin/bash
                echo "Hello, World" > index.html
                nohup busybox httpd -f -p ${var.server_port} &
                EOF
    lifecycle {
        create_before_destroy = true
    }
}

resource "aws_autoscaling_group" "autoinsta" {
    launch_configuration = aws_launch_configuration.auto.name
    availability_zones   = data.aws_subnet.default.id
    vpc_zone_identifier  = data.aws_subnet.default.id
    
    target_group_arns = [aws_lb_target_group.asg.arn]
    health_check_type = "ELB"
    min_size = 2
    max_size = 10

    tag {
        key = "Name"
        value = "terraform-asg"
        propagate_at_launch = true
    }
}


data "aws_vpc" "main" {
tags = {
    terraform = "true"
    env       = "lab"
    }
}

data "aws_subnet" "default" {
    vpc_id = data.aws_vpc.main.id
    filter {
        name = "vpc-id"
        values = ["true"]
    }
}


resource "aws_lb_listener_rule" "asg" {
    listener_arn = aws_lb_listener.http.arn
    priority     = 100
    
    condition {
        path_pattern {
            values = ["*"]
        }
    }
    action {
        type = "forward"
        target_group_arn = aws_lb_target_group.asg.arn
    }
}

resource "aws_lb" "main" {
    name               = "test-lb"
    load_balancer_type = "application"
    subnets = data.aws_subnet.default.id
    security_groups = [aws_security_group.alb.id]

}

resource "aws_lb_target_group" "asg" {
    name = "asgtarget"
    port = var.server_port
    protocol = "HTTP"
    target_type = "instance"
    vpc_id = data.aws_vpc.main.id

    health_check {
        path = "/"
        protocol = "HTTP"
        interval = 15
        matcher  = "200"
        timeout = 3
        healthy_threshold = 2
        unhealthy_threshold = 2
    }
    }
resource "aws_lb_listener" "http" {
    load_balancer_arn = aws_lb.main.arn
    port              = 80
    protocol          = "HTTP"
    # By default, return a simple 404 page
    default_action {
    type = "fixed-response"

    fixed_response {
        content_type = "text/plain"
        message_body = "404: Page not found"
        status_code = 404
    }
    }
}

resource "aws_security_group" "alb" {
    name   = "allow_tls"
    description = "Allow TLS inbound traffic"

    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    
    egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    }
}

output "public_ip" {
    value = aws_instance.terra.public_ip
    description = "The public IP address of the EC2 instance"
}


output "alb_dns_name" {
    value = aws_lb.main.dns_name
    description = "The DNS name of the ALB"
}