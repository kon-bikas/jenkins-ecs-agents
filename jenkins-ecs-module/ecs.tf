resource "aws_ecs_cluster" "jenkins_ecs_cluster" {
  name = "jenkins_ecs"

  configuration {
    execute_command_configuration {
      logging = "OVERRIDE"

      log_configuration {
        cloud_watch_log_group_name = aws_cloudwatch_log_group.cw_group.name
      }
    }
  }
}

resource "aws_ecs_cluster_capacity_providers" "cluster_cp" {
  cluster_name = aws_ecs_cluster.jenkins_ecs_cluster.name

  capacity_providers = ["FARGATE", "FARGATE_SPOT"]

  default_capacity_provider_strategy {
    base              = 1
    weight            = 100
    capacity_provider = "FARGATE"
  }
}

resource "aws_ecs_task_definition" "example_task_def" {
  count = length(var.task_definitions)

  family = var.task_definitions[count.index].family_name
  container_definitions = templatefile("${path.module}/templates/container_def.json.tftpl", {
    cont_image  = var.task_definitions[count.index].container.image,
    cont_cpu    = var.task_definitions[count.index].cpu,
    cont_memory = var.task_definitions[count.index].memory,
    cw_name     = var.task_definitions[count.index].container.cw_name
  })

  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  task_role_arn            = aws_iam_role.ecs_task_role.arn
  execution_role_arn       = aws_iam_role.ecs_task_role.arn
  cpu                      = var.task_definitions[count.index].cpu
  memory                   = var.task_definitions[count.index].memory

  runtime_platform {
    cpu_architecture        = "X86_64"
    operating_system_family = "LINUX"
  }

  tags = {
    Name = "${var.task_definitions[count.index].name_tag}"
  }

}