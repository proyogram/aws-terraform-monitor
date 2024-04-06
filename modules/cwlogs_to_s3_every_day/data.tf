data "aws_caller_identity" "current" {}

# lambdaソースをzip化してupload
data "archive_file" "archieve_lambda" {
  for_each = toset(local.functions)

  type        = "zip"
  source_dir  = "${path.module}/lambda_src/${each.key}"
  output_path = "${path.module}/lambda_src_zip/${each.key}/lambda.zip"
}

# policy関連のdata
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
      "ec2:Describe*",
      "secretsmanager:GetSecretValue",
      "s3:PutObject",
      "logs:DescribeLogGroups",
      "logs:CreateExportTask",
      "logs:DescribeExportTasks"
    ]
    resources = ["*"]
  }
}

data "aws_iam_policy_document" "assume_eventbridge_scheduler" {
  statement {
    effect = "Allow"

    actions = [
      "sts:AssumeRole",
    ]

    principals {
      type = "Service"
      identifiers = [
        "scheduler.amazonaws.com",
      ]
    }
  }
}

data "aws_iam_policy_document" "inline_eventbridge_scheduler" {
  statement {
    effect = "Allow"

    actions = [
      "states:StartExecution",
    ]

    resources = [
      "*",
    ]
  }
}

data "aws_iam_policy_document" "assume_sfn" {
  statement {
    sid    = ""
    effect = "Allow"

    principals {
      identifiers = ["states.amazonaws.com"]
      type        = "Service"
    }

    actions = ["sts:AssumeRole"]
  }
}

data "aws_iam_policy_document" "inline_sfn" {
  statement {
    effect = "Allow"

    actions = [
      "lambda:InvokeFunction",
    ]

    resources = [
      "*",
    ]
  }
}

data "aws_iam_policy_document" "bucket_policy" {
  statement {
    principals {
      type        = "Service"
      identifiers = ["logs.amazonaws.com"]
    }

    actions = [
      "s3:PutObject",
      "s3:GetBucketAcl"
    ]

    resources = [
      aws_s3_bucket.main.arn,
      "${aws_s3_bucket.main.arn}/*",
    ]
  }
}
