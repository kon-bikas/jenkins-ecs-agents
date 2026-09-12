module "jenkins_ecs" {
  source = "./jenkins-ecs-module"

  jenkins_instance_type = "t3.medium"
  jenkins_ssh_key_path  = "~/.ssh/jenkins_ssh.pub"
  my_public_ip = var.pub_ip

  task_definitions = [
      {
            name_tag = "kaniko-builder"
            family_name = "image-builder"
            container = {
                  image = "138465306868.dkr.ecr.eu-west-3.amazonaws.com/devops/jenkins-kaniko:latest"
                  cw_name = var.cloudwatch_name
            },
            cpu = "2048",
            memory = "4096"
      }
  ]
}

variable "pub_ip" {
  type = string
}

variable "cloudwatch_name" {
  description = "The name of the CloudWatch group to make"
  type        = string
  default     = "ecs-jenkins-log"
}