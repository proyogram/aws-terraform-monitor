resource "aws_lambda_function" "main" {
  function_name    = "${var.prefix}-lambda-main"
  filename         = data.archive_file.archieve_lambda.output_path
  role             = aws_iam_role.lambda.arn
  handler          = "lambda.lambda_handler"
  source_code_hash = data.archive_file.archieve_lambda.output_base64sha256
  runtime          = "python3.10"
  timeout          = 120
  environment {
    variables = {
      DESTINATION_BUCKET_NAME = aws_s3_bucket.main.id
      ACCOUNT_ID              = data.aws_caller_identity.current.account_id
      ROLE_NAME_FOR_KDF       = aws_iam_role.firehose.name
      ROLE_NAME_FOR_LOGS      = aws_iam_role.cw_logs.name
    }
  }
}

# event_schedule用の許可設定
resource "aws_lambda_permission" "schedule" {
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.main.arn
  principal     = "events.amazonaws.com"
  source_arn    = aws_scheduler_schedule.schedule.arn
}

# event_trigger用の許可設定
resource "aws_lambda_permission" "trigger" {
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.main.arn
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.trigger.arn
}
