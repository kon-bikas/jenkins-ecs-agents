# resource "aws_key_pair" "cluster_ssh_key" {
#   key_name   = var.jenkins_ssh_key_name
#   public_key = file(var.jenkins_ssh_key_path)
# }

resource "aws_instance" "jenkins-controller-ec2" {
  ami                         = "ami-04df1508c6be5879e"
  instance_type               = var.jenkins_instance_type
  key_name                    = "jenkins-ssh"
  subnet_id                   = var.jenkins_subnet
  vpc_security_group_ids      = [aws_security_group.jenkins_sg.id]
  iam_instance_profile        = aws_iam_instance_profile.jenkins_role_profile.name
  associate_public_ip_address = true

  ebs_block_device {
    device_name = "/dev/sda1"
    iops        = 3000
    volume_type = "gp3"
    volume_size = 8
  }

  tags = {
    Name = "jenkins-contoller"
  }
}