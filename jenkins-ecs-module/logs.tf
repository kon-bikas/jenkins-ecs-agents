resource "aws_cloudwatch_log_group" "cw_group" {
  name = "/ecs/${var.cloudwatch_name}/logs"

  tags = {
    Name = "${var.cloudwatch_name}-ecs-log-group"
  }
}