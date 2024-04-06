resource "aws_lambda_function" "main" {
  for_each = toset(local.functions)

  function_name    = "${var.prefix}-${each.key}"
  filename         = "${path.module}/lambda_src_zip/${each.key}/lambda.zip"
  role             = aws_iam_role.lambda.arn
  handler          = "lambda.lambda_handler"
  source_code_hash = filebase64sha256("${path.module}/lambda_src_zip/${each.key}/lambda.zip")
  runtime          = "python3.10"
  timeout          = 30
  environment {
    variables = {
      EXPORT_BUCKET = aws_s3_bucket.main.id
    }
  }
}
