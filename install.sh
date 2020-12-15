#!/bin/bash

#check product exist or not
if [ -d "/usr/local/SimpDLP-EP" ]
then
	echo "SimpDLP-EP is already installed!!!"
	exit 1
fi

#check product is installed in root user
if [ $UID -ne 0 ]
then
	echo "Permission denied, please install in root user!!!"
	exit 1
fi

echo "Step 1: starting to install SimpDLP-EP product......"
lines=80
tail -n +$lines $0 >/tmp/SimpDLP-EP.tar.gz
if [[ $? -ne 0 ]]
then
	echo "Get product data error, then exit!!"
	exit 1
fi

echo "Step 2: decompressioning files, please wait......"
tar -zxf /tmp/SimpDLP-EP.tar.gz  -C /usr/local
if [[ $? -ne 0 ]]
then
	echo "Decompress files error, then exit!!"
	exit 1
fi

chmod -R 777 /usr/local/SimpDLP-EP
rm /tmp/SimpDLP-EP.tar.gz

echo "Step 3: set environment variable"
if  ! grep -w "export SP_HOME=/usr/local/SimpDLP-EP" /etc/profile
then
	echo "export SP_HOME=/usr/local/SimpDLP-EP" >> /etc/profile
	echo "ulimit  -c unlimited" >> /etc/profile
	source /etc/profile
	echo "SP_HOME:" $SP_HOME
fi

echo "step4: config ld.so.conf"
if ! grep -w "Libs" /etc/ld.so.conf.d/spinfo-x86_64.conf >/dev/null 2>&1
then 
    echo "${SP_HOME}/Libs" >> /etc/ld.so.conf.d/spinfo-x86_64.conf
    echo "${SP_HOME}/COMMON/windows_wervice_file" >> /etc/ld.so.conf.d/spinfo-x86_64.conf
    #ldconfig > /dev/null
fi

echo "step4: config init.d"
ldconfig
#copy start script to init.d
chmod -R 755 ${SP_HOME}/run/

cp -f ${SP_HOME}/DepClient/DepAgent.desktop /etc/xdg/autostart

#Copy current dir server.xml
cd `dirname $0`
dir=`pwd`
echo $dir
cp -f $dir/server.xml ${SP_HOME}/COMMON/Config/server.xml

for i in `ls ${SP_HOME}/run/`
do
    cp -f ${SP_HOME}/run/$i /etc/rc.d/init.d/
      #service $i start
	chkconfig --add /etc/rc.d/init.d/$i
	#systemctl enable $i.service

    
done

#echo "Step 4: install auto-starting modules"
echo "请重启电脑完成安装"
exit 0
