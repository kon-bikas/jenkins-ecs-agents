variable "cloudwatch_name" {
  description = "The name of the CloudWatch group to make"
  type        = string
  default     = "jenkins-logs"
}

variable "agent_tunnel_port" {
  description = "Port that the fargate agent will reach to communicate with the jenkins controller"
  type        = number
  default     = 5000
}

variable "ecs_clusters" {
  type    = list(string)
  default = ["jenkins_ecs_cluster"]
}

variable "task_definitions" {
  type = list(object({
    name_tag    = string
    family_name = string
    container = object({
      image   = string
      cw_name = string
    }),
    cpu    = string
    memory = string
  }))
}

variable "vpc_id" {
  type    = string
  default = "vpc-0a0c16129cd4e9a26"
}

variable "my_public_ip" {
  type = string
}

variable "jenkins_ssh_key_name" {
  type    = string
  default = "jenkins-key"
}

variable "jenkins_ssh_key_path" {
  type = string
}

variable "jenkins_instance_type" {
  type    = string
  default = "t3.micro"
}

variable "jenkins_subnet" {
  type = string
  default = "subnet-020b488a8d6851690"
}