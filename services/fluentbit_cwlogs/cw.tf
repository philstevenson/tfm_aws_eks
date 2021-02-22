resource "aws_cloudwatch_log_group" "fluentbit_cwlogs" {
  name = var.log_group_name

  tags              = var.tags
  retention_in_days = var.retention_in_days
}
