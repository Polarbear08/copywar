#!/bin/bash

## 変数設定 ###############################################
# もとのwarファイルの名前
originalWarName=examples

# 作成するwarファイルの名前
targetWarName=examples3

# 接続するDBの情報(MySQL)
dbUser=root
dbPass=P@ssw0rd
dbHostName=localhost
dbPortNumber=3306
schemaName=${targetWarName}

# ProxyPassを設定するファイルの名前
proxyConfFile=/etc/httpd/conf.d/proxy.conf

# tomcatのwebappsディレクトリ
webapps=/opt/tomcat/webapps

## 関数 ##################################################
function sayDone() {
    echo -e "done!\n"
}

## 処理実行 ##############################################
echo "warファイルの名前を設定"
originalWarFile=${originalWarName}.war
targetWarFile=${targetWarName}.war
echo "元ファイル：${originalWarFile}"
echo "作成ファイル：${targetWarFile}"
echo ""

echo "STEP1/4 create schema and insert data into MySQL"
# スキーマを作成・データ流入
mysql -u ${dbUser} -p${dbPass} -P ${dbPortNumber} -h ${dbHostName} -e "create database if not exists ${schemaName};" 
sayDone

echo "STEP2/4 make customized WAR"
# ワーキングディレクトリでwarファイルを展開
mkdir work
cp ${originalWarFile} work/
cd work
jar xf ${originalWarFile}
rm ${originalWarFile}

# 必要な部分を書き換え
sed -i -e "s/Apache Tomcat Examples/Kaizan Shimasita/g" index.html

# warファイルを作成
jar cf ../${targetWarFile} .
cd ../
rm -rf work
chown tomcat:tomcat ${targetWarFile}
sayDone

echo "STEP3/4 deploy WAR file to Tomcat"
# デプロイ
mv -f ${targetWarFile} ${webapps}
sayDone

echo "STEP4/4 set reverse proxy (Apache httpd)"
# リバースプロキシの情報設定
echo "ProxyPass /${targetWarName} ajp://localhost:8009/${targetWarName}" >> ${proxyConfFile}
echo "ProxyPassReverse /${targetWarName} ajp://localhost:8009/${targetWarName}" >> ${proxyConfFile}
echo "" >> ${proxyConfFile}

# httpdを再起動
systemctl restart httpd
sayDone

echo -e "complete!!\n"
