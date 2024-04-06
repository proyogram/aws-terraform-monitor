# lambda用のiamロールを定義
resource "aws_iam_role" "lambda" {
  name               = "${var.prefix}-role-for-lambda"
  assume_role_policy = data.aws_iam_policy_document.assume_lambda.json
  inline_policy {
    name   = "${var.prefix}-inline-policy-for-lambda"
    policy = data.aws_iam_policy_document.inline_lambda.json
  }
}

# lambda用のiamロールにマネージドポリシーをアタッチ
resource "aws_iam_role_policy_attachment" "lambda_execution_role" {
  role       = aws_iam_role.lambda.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# eventbridge_trigger用のiamロールを定義
resource "aws_iam_role" "event_trigger" {
  name               = "${var.prefix}-role-for-eventtrigger"
  assume_role_policy = data.aws_iam_policy_document.assume_event_trigger.json
  inline_policy {
    name   = "${var.prefix}-inline-policy-for-trigger"
    policy = data.aws_iam_policy_document.inline_event_trigger.json
  }
}

# eventbridge_scheduler用のiamロールを定義
resource "aws_iam_role" "event_scheduler" {
  name               = "${var.prefix}-role-for-event"
  assume_role_policy = data.aws_iam_policy_document.assume_event_scheduler.json
  inline_policy {
    name   = "${var.prefix}-inline-policy-for-event"
    policy = data.aws_iam_policy_document.inline_event_scheduler.json
  }
}

# firehose用のロールを作成
resource "aws_iam_role" "firehose" {
  name               = "${var.prefix}-role-for-firehose"
  assume_role_policy = data.aws_iam_policy_document.assume_firehose.json
  inline_policy {
    name   = "${var.prefix}-inline-policy-for-firehose"
    policy = data.aws_iam_policy_document.inline_firehose.json
  }
}

# CloudWatch logs用のロールを作成
resource "aws_iam_role" "cw_logs" {
  name               = "${var.prefix}-role-for-cw-logs"
  assume_role_policy = data.aws_iam_policy_document.assume_cw_logs.json
  inline_policy {
    name   = "${var.prefix}-inline-policy-for-cw-logs"
    policy = data.aws_iam_policy_document.inline_cw_logs.json
  }
}
