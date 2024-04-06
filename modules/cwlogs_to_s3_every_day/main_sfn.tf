resource "aws_sfn_state_machine" "main" {
  name     = "${var.prefix}-state-machine"
  role_arn = aws_iam_role.sfn.arn

  definition = <<EOF
{
  "StartAt": "Configure",
  "TimeoutSeconds": 82800,
  "States": {
    "Configure": {
      "Type": "Pass",
      "Result": {
        "index": 0,
        "day": 0
      },
      "ResultPath": "$.iterator",
      "Next": "DescribeLogGroups"
    },
    "DescribeLogGroups": {
      "Type": "Task",
      "Resource": "arn:aws:lambda:ap-northeast-1:${data.aws_caller_identity.current.account_id}:function:${var.prefix}-describe_loggroups",
      "ResultPath": "$.describe_log_groups",
      "Next": "ExportLogGroup"
    },
    "ExportLogGroup": {
      "Type": "Task",
      "Resource": "arn:aws:lambda:ap-northeast-1:${data.aws_caller_identity.current.account_id}:function:${var.prefix}-allocate_export_task",
      "ResultPath": "$.iterator",
      "Next": "DescribeExportTask"
    },
    "DescribeExportTask": {
      "Type": "Task",
      "Resource": "arn:aws:lambda:ap-northeast-1:${data.aws_caller_identity.current.account_id}:function:${var.prefix}-describe_export_task",
      "ResultPath": "$.describe_export_task",
      "Next": "IsExportTask"
    },
    "IsExportTask": {
      "Type": "Choice",
      "Choices": [
        {
          "Variable": "$.describe_export_task.status_code",
          "StringEquals": "COMPLETED",
          "Next": "IsComplete"
        },
        {
          "Or": [
            {
              "Variable": "$.describe_export_task.status_code",
              "StringEquals": "PENDING"
            },
            {
              "Variable": "$.describe_export_task.status_code",
              "StringEquals": "RUNNING"
            }
          ],
          "Next": "WaitSeconds"
        }
      ],
      "Default": "Fail"
    },
    "WaitSeconds": {
      "Type": "Wait",
      "Seconds": 5,
      "Next": "DescribeExportTask"
    },
    "IsComplete": {
      "Type": "Choice",
      "Choices": [
        {
          "Variable": "$.iterator.end_flg",
          "BooleanEquals": true,
          "Next": "Succeed"
        }
      ],
      "Default": "ExportLogGroup"
    },
    "Succeed": {
      "Type": "Succeed"
    },
    "Fail": {
      "Type": "Fail"
    }
  }
}
EOF
}
