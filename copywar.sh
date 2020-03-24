co  #!/bin/bash

## 変数設定 ###########################################
# もとのwarファイルの名前
originalWarName=examples

# 作成するwarファイルの名前
targetWarName=examples4

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


## war作成処理 ###########################################
## warファイル名を設定
originalWarFile=${originalWarName}.war
targetWarFile=${targetWarName}.war

## Apache
# リバースプロキシの情報設定
echo "ProxyPass /${targetWarName} ajp://localhost:8009/${targetWarName}" >> ${proxyConfFile}
echo "ProxyPassReverse /${targetWarName} ajp://localhost:8009/${targetWarName}" >> ${proxyConfFile}

## MySQL
# スキーマを作成・データ流入
mysql -u ${dbUser} -p${dbPass}　-P ${dbPortNumber} -h ${dbHostName} -e "create database if not exists ${schemaName};" 

## warファイル
# ワーキングディレクトリでwarファイルを展開
mkdir work
cp ${originalWarFile} work/
cd work
jar xvf ${originalWarFile}
rm ${originalWarFile}

# 必要な部分を書き換え
sed -i -e "s/Apache Tomcat Examples/Kaizan Shimasita/g" index.html

# warファイルを作成
jar cvf ../${targetWarFile} .
cd ../
rm -rf work
chown tomcat:tomcat ${targetWarFile}

## Tomcat
# デプロイ
mv ${targetWarFile} ${webapps}


# httpdを再起動
systemctl restart httpd