resource "aws_sns_topic" "main" {
  name = "${var.prefix}-topic"
}

resource "aws_sns_topic_policy" "main" {
  arn    = aws_sns_topic.main.arn
  policy = data.aws_iam_policy_document.sns_topic_policy.json
}
