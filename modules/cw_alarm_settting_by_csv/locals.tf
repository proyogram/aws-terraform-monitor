# Google Sheets「https://docs.google.com/spreadsheets/d/1T5qaPBQgazL5t9NiqjJ4H6QULjfJoa5Qej9NKPqEa_s/edit?usp=sharing」からcsvを作成。
locals {
  alarm = csvdecode(file("${path.module}/csv/cw_alarm.csv"))
}

locals {
  math_alarm = csvdecode(file("${path.module}/csv/cw_math_alarm.csv"))
}
