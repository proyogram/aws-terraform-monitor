variable "prefix" {
  type        = string
  description = "全てのリソースの文字前に付与される値"
}

variable "cron_set_schedule" {
  type        = string
  description = "スケジュールをcronで表現"
}

variable "retention_days" {
  type        = string
  description = "ロググループに設定する保持期間"
}
