variable "prefix" {
  type        = string
  description = "全てのリソースの文字前に付与される値"
}

variable "subsc_mails" {
  type        = list(any)
  description = "SNSサブスクリプション用メールアドレスリスト"
}
