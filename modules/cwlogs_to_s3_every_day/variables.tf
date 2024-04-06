variable "prefix" {
  type        = string
  description = "全てのリソースの文字前に付与される値"
}

variable "cron_schedule" {
  type        = string
  description = "EventBridgeを実行させるスケジュールをcronで定義"
}
