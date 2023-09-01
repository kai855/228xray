cd ${0%/*}
chmod -R 777 .
. ./config.ini
${0%/*}/*/"xray".bin check

./核心/yyds1 -d

#./核心/"$exec".bin check
./核心/"sohigh".bin start