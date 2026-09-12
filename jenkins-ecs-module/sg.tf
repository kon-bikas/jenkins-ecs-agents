resource "aws_security_group" "ecs_task_sg" {
  name   = "ecs_task_sg"
  vpc_id = var.vpc_id

  tags = {
    Name = "ecs_task_sg"
  }
}

resource "aws_vpc_security_group_egress_rule" "ecs_all_outbound" {
  security_group_id = aws_security_group.ecs_task_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = -1
}


resource "aws_security_group" "jenkins_sg" {
  name   = "jenkins_sg"
  vpc_id = var.vpc_id

  tags = {
    Name = "jenkins_sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "ecs_jenkins_rule" {
  security_group_id            = aws_security_group.jenkins_sg.id
  referenced_security_group_id = aws_security_group.ecs_task_sg.id
  ip_protocol                  = "tcp"
  from_port = var.agent_tunnel_port
  to_port                      = var.agent_tunnel_port
}

resource "aws_vpc_security_group_ingress_rule" "ssh_access_rule" {
  security_group_id = aws_security_group.jenkins_sg.id
  cidr_ipv4         = "${var.my_public_ip}/32"
  ip_protocol       = "tcp"
  from_port         = 22
  to_port           = 22
}

resource "aws_vpc_security_group_ingress_rule" "ui_access_rule" {
  security_group_id = aws_security_group.jenkins_sg.id
  cidr_ipv4         = "${var.my_public_ip}/32"
  ip_protocol       = "tcp"
  from_port         = 8080
  to_port           = 8080
}

resource "aws_vpc_security_group_egress_rule" "jenkins_all_outbound" {
  security_group_id = aws_security_group.jenkins_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = -1
}