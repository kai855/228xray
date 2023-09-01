cd /data/xray
chmod -R 777 .
. ./config.ini
./核心/"$exec".bin stop

/data/xray/核心/yyds1 -d

# ./核心/"sohigh".bin start