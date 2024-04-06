resource "aws_cloudwatch_event_rule" "trigger" {
  name        = "${var.prefix}-event-trigger"
  description = "Create Log Group Events"

  event_pattern = jsonencode({
    source      = ["aws.logs"],
    detail-type = ["AWS API Call via CloudTrail"],
    detail = {
      eventSource = ["logs.amazonaws.com"],
      eventName   = ["CreateLogGroup"]
    }
  })
}

resource "aws_cloudwatch_event_target" "trigger" {
  rule = aws_cloudwatch_event_rule.trigger.name
  arn  = aws_lambda_function.main.arn
}

resource "aws_scheduler_schedule" "schedule" {
  name                         = "${var.prefix}-event-monthly"
  group_name                   = aws_scheduler_schedule_group.schedule.name
  state                        = "ENABLED"
  schedule_expression          = var.cron_create_schedule
  schedule_expression_timezone = "Asia/Tokyo"

  flexible_time_window {
    mode = "OFF"
  }

  target {
    arn      = aws_lambda_function.main.arn
    role_arn = aws_iam_role.event_scheduler.arn
  }
}

resource "aws_scheduler_schedule_group" "schedule" {
  name = "${var.prefix}-event-monthly-schedule-group"
}
