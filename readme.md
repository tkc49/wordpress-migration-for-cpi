# WordPress Migration for CPI
このシェルスクリプトはCPIサーバーで運用しているWordPressのデータベース、プラグイン、uploadsのデータをテスト環境やVCCWでの開発環境へ取り込むことができます。

## 準備
1. wordpress-migration-for-cpi.sh のファイルをvccwの配下に設置する
2. wordpress-migration-for-cpi.sh ファイルを開く
3. 以下の情報を書き換える

```
################################
# Setting informaiton
################################
# ssh 
ssh_command_staging=""
ssh_command_prod=""

# url
local_url="http://local.test"
staging_url="https://test.smartrelease.jp"
production_url="https://your-domain"

# dir name and file name
wp_root="html"
wp_content_path="html/wp-content"
plugins_dir="plugins"
uploads_dir="uploads"
export_file_name="export.sql"

# ベーシック認証
user=""
password=""
```

### ssh_command_staging, ssh_command_prod とは

`~/.ssh/config` に追加したhost名を記載してください。


## 使い方
`sh wordpress-migration-for-cpi.sh {db or plugin or upload} {staging or local} `

### 本番環境のデータベースをテスト環境へ反映する
`sh wordpress-migration-for-cpi.sh db staging`

### 本番環境のプラグインをテスト環境へ反映する
`sh wordpress-migration-for-cpi.sh plugin staging`

### 本番環境のuploadsディレクトリーをテスト環境へ反映する
`sh wordpress-migration-for-cpi.sh uploads`


### テスト環境のデータベースを開発環境へ反映する
`sh wordpress-migration-for-cpi.sh db local`

### テスト環境のプラグインを開発環境へ反映する
`sh wordpress-migration-for-cpi.sh plugin local`
