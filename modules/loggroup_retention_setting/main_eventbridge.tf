resource "aws_scheduler_schedule_group" "main" {
  name = "${var.prefix}-event-monthly-schedule-group"
}

resource "aws_scheduler_schedule" "main" {
  name       = "${var.prefix}-event-monthly"
  group_name = aws_scheduler_schedule_group.main.name

  state = "ENABLED"

  schedule_expression          = var.cron_set_schedule
  schedule_expression_timezone = "Asia/Tokyo"

  flexible_time_window {
    mode = "OFF"
  }

  target {
    arn      = aws_lambda_function.main.arn
    role_arn = aws_iam_role.eventbridge_scheduler.arn
  }
}
