resource "aws_scheduler_schedule_group" "main" {
  name = "${var.prefix}_event_weekly_schedule_group"
}

resource "aws_scheduler_schedule" "main" {
  name                         = "${var.prefix}-scheduler"
  group_name                   = aws_scheduler_schedule_group.main.name
  state                        = "ENABLED"
  schedule_expression          = var.cron_schedule
  schedule_expression_timezone = "Asia/Tokyo"

  flexible_time_window {
    mode = "OFF"
  }

  target {
    arn      = aws_sfn_state_machine.main.arn
    role_arn = aws_iam_role.eventbridge_scheduler.arn
  }
}
