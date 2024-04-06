# aws-terraform-monitor
本リポジトリは、「AWS 監視関連」のterraformコードを管理している。

## 前提

本モジュールでは、terraformのtfstateファイルを保管するS3バケットを作成する必要がある。
作成したS3バケット名をprovider.tfの`<BACKEND_BUCKET_NAME>`に設定する。
