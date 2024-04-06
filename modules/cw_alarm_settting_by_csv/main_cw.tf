resource "aws_cloudwatch_metric_alarm" "alarm" {
  for_each = { for alarm in local.alarm : alarm.id => alarm }

  alarm_name          = each.value.alarm_name
  comparison_operator = each.value.comparison_operator
  evaluation_periods  = each.value.evaluation_periods
  metric_name         = each.value.metric_name
  namespace           = each.value.namespace
  period              = each.value.period
  statistic           = each.value.statistic
  threshold           = each.value.threshold
  alarm_description   = each.value.alarm_description
  dimensions          = jsondecode("${each.value.dimensions}")
  alarm_actions       = [aws_sns_topic.main.arn]
}

resource "aws_cloudwatch_metric_alarm" "math_alarm" {
  for_each = { for math_alarm in local.math_alarm : math_alarm.id => math_alarm }

  alarm_name          = each.value.name
  comparison_operator = each.value.comparison_operator
  evaluation_periods  = each.value.evaluation_periods
  threshold           = each.value.threshold
  alarm_description   = each.value.alarm_description
  alarm_actions       = [aws_sns_topic.main.arn]

  metric_query {
    id          = "e1"
    expression  = each.value.expression
    label       = each.value.label
    return_data = "true"
  }

  metric_query {
    id = "m1"

    metric {
      metric_name = each.value.metric_name_m1
      namespace   = each.value.namespace_m1
      period      = each.value.period_m1
      stat        = each.value.stat_m1

      dimensions = jsondecode("${each.value.dimensions_m1}")
    }
  }

  metric_query {
    id = "m2"

    metric {
      metric_name = each.value.metric_name_m2
      namespace   = each.value.namespace_m2
      period      = each.value.period_m2
      stat        = each.value.stat_m2

      dimensions = jsondecode("${each.value.dimensions_m2}")
    }
  }
}
