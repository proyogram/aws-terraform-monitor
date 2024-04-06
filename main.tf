module "loggroup_retention_setting" {
  source            = "./modules/loggroup_retention_setting"
  prefix            = "tf-logs-retention"
  cron_set_schedule = "cron(0 22 1 * ? *)"
  retention_days    = 30
}

module "all_cwlogs_to_s3_by_firehose" {
  source               = "./modules/all_cwlogs_to_s3_by_firehose"
  prefix               = "tf-logs-create-firehose-subfil"
  cron_create_schedule = "cron(0 22 1 * ? *)"
}

module "cw_alarm_settting_by_csv" {
  source      = "./modules/cw_alarm_settting_by_csv"
  prefix      = "tf-cw-alarm"
  subsc_mails = ["aaa@xxx.com"]
}

module "cwlogs_to_s3_every_day" {
  source        = "./modules/cwlogs_to_s3_every_day"
  prefix        = "tf-cwlogs-s3"
  cron_schedule = "cron(0 22 * * ? *)"
}

module "cwlogs_to_s3_by_firehose" {
  source = "./modules/cwlogs_to_s3_by_firehose"
  prefix = "tf-cwlogs-firehose-s3"
  loggroups = [
    {
      loggroup_name_id = "tmp-cost-over-alert-from-sns"
      loggroup_name    = "/aws/lambda/tmp-cost-over-alert-from-sns"
    },
    {
      loggroup_name_id = "tf-codepipeline-project"
      loggroup_name    = "/aws/codebuild/tf-codepipeline-project"
    },
    {
      loggroup_name_id = "lambda-delivery-stream"
      loggroup_name    = "/aws/kinesisfirehose/lambda-delivery-stream"
    },
  ]
}
