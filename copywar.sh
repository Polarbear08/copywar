#!/bin/bash

# 変数設定
originalWarName=examples
originalWarFile=${originalWarName}.war
targetWarName=examples3
targetWarFile=${targetWarName}.war
proxyConfFile=/etc/httpd/conf.d/proxy.conf
webapps=/opt/tomcat/webapps
dbUser=root
dbPass=P@ssw0rd
schema=${targetWarName}


#echo ${targetWarName}
#echo ${proxyConfFile}
# ProxyPass設定
echo "ProxyPass /${targetWarName} ajp://localhost:8009/${targetWarName}" >> ${proxyConfFile}
echo "ProxyPassReverse /${targetWarName} ajp://localhost:8009/${targetWarName}" >> ${proxyConfFile}

# DB設定
mysql -u ${dbUser} -p${dbPass} -e "create database if not exists ${schema};" 

# war設定
mkdir work
cp ${originalWarFile} work/
cd work
jar xvf ${originalWarFile}
rm ${originalWarFile}
sed -i -e "s/Apache Tomcat Examples/Kaizan Shimasita/g" index.html
jar cvf ../${targetWarFile} .
cd ../
chown tomcat:tomcat ${targetWarFile}
mv ${targetWarFile} ${webapps}

systemctl restart httpd