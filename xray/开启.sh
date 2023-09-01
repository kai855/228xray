#!/system/bin/sh

cd /data/xray
./核心/"xray".bin start
chmod -R 777 .
. ./config.ini
./核心/11.bin start