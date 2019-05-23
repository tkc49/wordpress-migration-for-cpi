#!/bin/sh
# $1: db or plugin or upload
# $2: staging or local

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

if [ $1 == "db" ]; then
	if [ $2 == "local" ]; then

		# テスト環境のデータベースをローカルの開発環境へ反映する
		echo "#### [テスト環境]DBエクスポート"
		ssh $ssh_command_staging "cd $wp_root;wp db export $export_file_name.zip;exit;"
		echo "#### [ローカル]インポート"
		if [ user == "" ]; then
			vagrant ssh -c "cd /vagrant/wordpress/;wget $staging_url/$export_file_name.zip;mv $export_file_name.zip $export_file_name;wp db import $export_file_name;wp search-replace '$staging_url' '$local_url';exit;"
		else
			vagrant ssh -c "cd /vagrant/wordpress/;wget --http-user=$user --http-passwd=$password $staging_url/$export_file_name.zip;mv $export_file_name.zip $export_file_name;wp db import $export_file_name;wp search-replace '$staging_url' '$local_url';exit;"
		fi
		echo "#### [テスト環境]DBデータ削除"
		ssh $ssh_command_staging "cd $wp_root;rm -rf $export_file_name.zip;exit;"

	elif [ $2 == "staging" ]; then

		# 本番環境のデータベースをテスト環境へ反映する
		echo "#### [本番環境]DBエクスポート"
		ssh $ssh_command_prod "cd $wp_root;wp db export $export_file_name.zip;exit;"
		echo "#### [テスト環境]本番のDBデータを取得"
		ssh $ssh_command_staging "cd $wp_root;wget $production_url/$export_file_name.zip --no-check-certificate;mv $export_file_name.zip $export_file_name;wp db import $export_file_name;wp search-replace '$production_url' '$staging_url';rm -rf $export_file_name;exit;"
		echo "#### [本番環境]DBデータ削除"
		ssh $ssh_command_prod "cd $wp_root;rm -rf $export_file_name.zip;exit;"
	else
		echo "２つ目の引数には local or staging  のコマンドを入力してください。"
	fi

elif [ $1 == "plugin" ]; then
	
	if [ $2 == "local" ]; then

		# テスト環境のプラグインをローカルの開発環境へ反映する
		echo "#### [テスト環境]DBエクスポート"
		ssh $ssh_command_staging "cd $wp_content_path;tar zcvf $plugins_dir.tar.gz $plugins_dir;exit;"
		echo "#### [ローカル]インポート"
		vagrant ssh -c "cd /vagrant/wordpress/wp-content;tar zcvf $plugins_dir-`date "+%Y%m%d_%H%M%S"`.tar.gz $plugins_dir --remove-file;wget --http-user=kakogawa --http-passwd=wr7ZiK3V $staging_url/wp-content/$plugins_dir.tar.gz;tar zxvf $plugins_dir.tar.gz;rm -rf $plugins_dir.tar.gz;exit;"
		echo "#### [テスト環境]DBデータ削除"
		ssh $ssh_command_staging "cd $wp_content_path;rm -rf $plugins_dir.tar.gz;exit;"
	elif [ $2 == "staging" ]; then

		# 本番環境のプラグインをテスト環境へ反映する
		echo "#### [本番環境]UPLOADSディレクトリをアーカイブ"
		ssh $ssh_command_prod "cd $wp_content_path;tar zcvf $plugins_dir.tar.gz $plugins_dir;exit;"
		echo "#### [テスト環境]本番のUPLOADSを取得"
		ssh $ssh_command_staging "cd $wp_content_path;mv $plugins_dir $plugins_dir.bk;wget $production_url/wp-content/$plugins_dir.tar.gz --no-check-certificate;tar zxvf $plugins_dir.tar.gz;exit;"
		echo "#### [本番環境]DBデータ削除"
		ssh $ssh_command_prod "cd $wp_content_path;rm -rf $plugins_dir.tar.gz;exit;"
		echo "#### [テスト環境]不要なファイル削除"
		ssh $ssh_command_staging "cd $wp_content_path;rm -rf $plugins_dir.tar.gz;rm -rf $plugins_dir.bk;exit;"
	else
		echo "２つ目の引数には local or staging  のコマンドを入力してください。"
	fi


elif [ $1 == "uploads" ]; then

	# 本番環境のUPLOADディレクトリーをテスト環境へ反映する
	echo "#### [本番環境]UPLOADSディレクトリをアーカイブ"
	ssh $ssh_command_prod "cd $wp_content_path;tar zcvf $uploads_dir.tar.gz $uploads_dir;exit;"
	echo "#### [テスト環境]本番のUPLOADSを取得"
	ssh $ssh_command_staging "cd $wp_content_path;mv $uploads_dir $uploads_dir.bk;wget $production_url/wp-content/$uploads_dir.tar.gz --no-check-certificate;tar zxvf $uploads_dir.tar.gz;exit;"
	echo "#### [本番環境]DBデータ削除"
	ssh $ssh_command_prod "cd $wp_content_path;rm -rf $uploads_dir.tar.gz;exit;"
	echo "#### [テスト環境]不要なファイル削除"
	ssh $ssh_command_staging "cd $wp_content_path;rm -rf $uploads_dir.tar.gz;rm -rf $uploads_dir.bk;exit;"
else
	echo "１つ目の引数には db or plugin or uploads のコマンドを入力してください。"
fi

