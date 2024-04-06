# Firehose
resource "aws_kinesis_firehose_delivery_stream" "main" {
  for_each = { for i in var.loggroups : i.loggroup_name_id => i }

  name        = "${var.prefix}-firehose-from-${each.value.loggroup_name_id}-to-s3"
  destination = "extended_s3"

  extended_s3_configuration {
    role_arn           = aws_iam_role.firehose.arn
    bucket_arn         = aws_s3_bucket.main.arn
    prefix             = "${each.value.loggroup_name_id}/"
    compression_format = "GZIP"
  }
}

# CloudWatch logs
resource "aws_cloudwatch_log_subscription_filter" "main" {
  for_each = { for i in var.loggroups : i.loggroup_name_id => i }

  name            = "${var.prefix}-subfil-to-firehose"
  role_arn        = aws_iam_role.cwlogs.arn
  log_group_name  = each.value.loggroup_name
  filter_pattern  = ""
  destination_arn = "arn:aws:firehose:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:deliverystream/${var.prefix}-firehose-from-${each.value.loggroup_name_id}-to-s3"

  depends_on = [
    aws_kinesis_firehose_delivery_stream.main
  ]
}

# S3
resource "aws_s3_bucket" "main" {
  bucket = "${var.prefix}-bucket-cw-logs"
}

resource "aws_s3_bucket_policy" "main" {
  bucket = aws_s3_bucket.main.id
  policy = data.aws_iam_policy_document.bucket_policy.json
}

resource "aws_s3_bucket_public_access_block" "main" {
  bucket                  = aws_s3_bucket.main.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# IAM
resource "aws_iam_role" "firehose" {
  name               = "${var.prefix}-role-for-firehose"
  assume_role_policy = data.aws_iam_policy_document.assume_firehose.json
  inline_policy {
    name   = "${var.prefix}-inline-policy-for-firehose"
    policy = data.aws_iam_policy_document.inline_firehose.json
  }
}

resource "aws_iam_role" "cwlogs" {
  name               = "${var.prefix}-role-for-cw-logs"
  assume_role_policy = data.aws_iam_policy_document.assume_cw_logs.json
  inline_policy {
    name   = "${var.prefix}-inline-policy-for-cw-logs"
    policy = data.aws_iam_policy_document.inline_cw_logs.json
  }
}
