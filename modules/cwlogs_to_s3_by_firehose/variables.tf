variable "prefix" {
  type        = string
  description = "全てのリソースの文字前に付与される値"
}

variable "loggroups" {
  type        = list(any)
  description = "S3に送信するログのロググループ"
}
