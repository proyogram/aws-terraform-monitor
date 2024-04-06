# AWSアカウントの取得
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

# data - policy_document
data "aws_iam_policy_document" "bucket_policy" {
  statement {
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${aws_iam_role.firehose.name}"]
    }

    actions = [
      "s3:PutObject",
    ]

    resources = [
      aws_s3_bucket.main.arn,
      "${aws_s3_bucket.main.arn}/*",
    ]
  }
}

data "aws_iam_policy_document" "assume_lambda" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "inline_lambda" {
  statement {
    actions = [
      "firehose:CreateDeliveryStream",
      "iam:PassRole",
      "logs:PutSubscriptionFilter",
      "logs:DescribeLogGroups",
      "logs:DescribeSubscriptionFilters"
    ]

    resources = ["*"]
  }
}

data "aws_iam_policy_document" "assume_firehose" {
  statement {
    effect = "Allow"

    actions = [
      "sts:AssumeRole",
    ]

    principals {
      type = "Service"
      identifiers = [
        "firehose.amazonaws.com",
      ]
    }
  }
}

data "aws_iam_policy_document" "inline_firehose" {
  statement {
    effect = "Allow"

    actions = [
      "s3:AbortMultipartUpload",
      "s3:GetBucketLocation",
      "s3:GetObject",
      "s3:ListBucket",
      "s3:ListBucketMultipartUploads",
      "s3:PutObject"
    ]

    resources = [
      aws_s3_bucket.main.arn,
      "${aws_s3_bucket.main.arn}/*",
    ]
  }

  statement {
    effect = "Allow"

    actions = [
      "logs:PutLogEvents"
    ]

    resources = [
      "*",
    ]
  }
}

data "aws_iam_policy_document" "assume_cw_logs" {
  statement {
    effect = "Allow"

    actions = [
      "sts:AssumeRole",
    ]

    principals {
      type = "Service"
      identifiers = [
        "logs.amazonaws.com",
      ]
    }
  }
}

data "aws_iam_policy_document" "inline_cw_logs" {
  statement {
    effect = "Allow"

    actions = [
      "firehose:PutRecord",
      "firehose:PutRecordBatch",
      "firehose:StartDeliveryStreamEncryption",
      "firehose:StopDeliveryStreamEncryption",
      "firehose:UpdateDestination"
    ]

    resources = [
      aws_s3_bucket.main.arn,
      "arn:aws:firehose:ap-northeast-1:${data.aws_caller_identity.current.account_id}:*",
    ]
  }
}
