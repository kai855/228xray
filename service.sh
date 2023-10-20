# 开机之后执行
#!/system/bin/sh
# 不要假设您的模块将位于何处。
# 如果您需要知道此脚本和模块的放置位置，请使用$MODDIR
# 这将确保您的模块仍能正常工作
# 即使Magisk将来更改其挂载点
MODDIR=/data/adb/modules/xray/module.prop

echo_magisk() {
 # 输出信息到面具
 echo id=xray > $MODDIR
 echo name=a$1 >> $MODDIR
 echo version=到期时间$target_date >> $MODDIR 
 echo versionCode=1430 >> $MODDIR
 echo author=KAI >> $MODDIR
 echo description=$2 >> $MODDIR
 echo $1 >>/data/xray/日志.txt
}

check_date() {
#检验时间
while true; do
today=$(date "+%Y%m%d")
     if [ "$today" -ge $target_date ]; then
        deadline
     fi
     
rm -r /data/xray/节点/pings.txt
sh /data/xray/延迟测试.sh
updata_geoip
start_v2
sleep 7200
done
}

start_v2() {

while read -r line
do
  sed -i "/$line/d" /data/xray/节点/ping1.txt
  sed -i "/$line/d" /data/xray/节点/ping2.txt
done < /data/xray/节点/pings.txt



 # 开启v2
   node_name1=$( cat /data/xray/节点/ping1.txt  | awk -F ',' '{print $1}'|head -n 1)
   node_delay1=$( cat /data/xray/节点/ping1.txt  | awk -F ',' '{print $2}'|head -n 1)
   node_name2=$( cat /data/xray/节点/ping2.txt  | awk -F ',' '{print $1}'|head -n 1)
   node_delay2=$( cat /data/xray/节点/ping2.txt  | awk -F ',' '{print $2}'|head -n 1)
   cd  /data/xray/
   sed -i "/file=/cfile=$node_name1,$node_name2" /data/xray/config.ini
   sed -i "/nodeswitch=/cnodeswitch=0" /data/xray/xray设置.txt
   echo "打开v2/切换节点" $(date "+%m-%d %H:%M:%S") >>/data/xray/日志.txt
   sh /data/xray/开启.sh &
   echo_magisk 当前节点内$node_name1，外$node_name2 "内延迟：$node_delay1，外延迟:$node_delay2"
   

}
check_ipl() {
while true; do
sleep 300
content=$(curl -s "cip.cc")  
# 使用grep命令检测是否包含“上海”这个关键词  
if echo "$content" | grep -q "上海"; then  
    echo "疑似使用通用流量" 
    deadline
fi

done
}
check_url() {
  # 使用curl命令，只返回状态码
  
  attempt=1
  while [[ $attempt -le 4 ]]
do
    eval "url=\$url$attempt"
    urlresult=$(curl -s --retry-connrefused -o /dev/null -w "%{http_code}"  -m 3 $url )
    # 检查HTTP响应代码是否成功
    if [[ $urlresult -eq 000 ]]; then       
        #sleep 1
        attempt=$((attempt+1))
        
    else break
    fi
done
  echo 测试$url结果$urlresult $(date "+%m-%d %H:%M:%S") >>/data/xray/日志.txt
    
}

check_net() {
     
     # 测试网络通断

     check_url 
     #echo $urlresult
     if [ "$urlresult" -eq 000 ]; then
     
       if [ -s $1 ]; then 
         #sed -i '1d' $1
         echo  $2 >> /data/xray/节点/pings.txt
       else rm -r /data/xray/节点/pings.txt
       fi
         sed -i "/nodeswitch=/cnodeswitch=1" /data/xray/xray设置.txt
         
       #else break
       
     fi
}

updata_geoip() {
 # 更新geoip

      echo 更新规则文件 >>/data/xray/日志.txt
      curl -o  tmp.dat -L https://ghproxy.com/https://raw.github.com/Loyalsoldier/geoip/release/cn.dat 
      mv tmp.dat /data/xray/核心/geoip.dat
      curl -o  tmp.dat -L https://ghproxy.com/https://github.com/Loyalsoldier/v2ray-rules-dat/releases/latest/download/geosite.dat 
      mv tmp.dat /data/xray/核心/geosite.dat
      echo 规则文件更新完毕 >>/data/xray/日志.txt
      
      sh /data/xray/节点订阅.sh
}

deadline() {
 # 到期断网
cd /data/xray/节点
rm -r *

echo_magisk 当前已到期或者走通用 内延迟：999，外延迟:999

while true; do
 urlresult=$(curl -s -o /dev/null -w "%{http_code}"  -m 2 "baidu.com")
 if [ "$urlresult" -ne 000 ]; then
   echo -e "addr=\"192.168.199.199:801\"
   uuid=\"123456789\"
   alterId=0
   security=\"auto\"
   method=\"ws\"
   type=\"none\"
   path=\"\"
   host=\"h5.dingtalk.com\"
   DNS=\"8.8.4.4\"
   " >  /data/xray/节点/断网.ini
   cd  /data/xray/
   sed -i "/file=/cfile=断网" config.ini
   sh /data/xray/开启.sh
 fi  
done
}

chmod -R 777 /data/xray

#初始化
renice -n -20 -p $$
proxy=$(awk -F'=' '/proxy/{print $2; exit}'  /data/xray/xray设置.txt)
target_date=$(awk -F'=' '/target_date/{print $2; exit}'  /data/xray/xray设置.txt)
sed -i "/update=/cupdate=0" /data/xray/xray设置.txt

sh  /data/xray/关闭.sh &
echo 开始启动 $(date "+%m-%d %H:%M:%S") >>/data/xray/日志.txt
sed -i "/nodeswitch=/cnodeswitch=0" /data/xray/xray设置.txt
#check_url qq.com
#while [ "$urlresult" -eq "000" ]; do
#  echo 等待开机网络 $(date "+%m-%d %H:%M:%S") >>/data/xray/日志.txt
#  check_url qq.com
#  sleep 1
#done

#if [ $(ls "/data/xray/节点" | wc -l) -eq 0 ]; then  
    # 如果文件夹为空，则运行p.sh脚本 
#    echo "不存在节点" >>/data/xray/日志.txt
#    sh /data/xray/节点订阅.sh
#else  
#    echo "存在节点" >>/data/xray/日志.txt
#fi



echo_magisk 正在测试节点 测试节点中，请稍后


 # 切换节点
check_date &
check_ipl &


while true; do
    
    sleep 60

    url1="https://baidu.com" 
    url2="https://qq.com" 
    url3="https://taobao.com" 
    url4="失败，"
    check_net /data/xray/节点/ping1.txt $node_name1 &
    pid1=$!
    
         #国外节点     
    if [[  $proxy -ne 0 ]]; then

      url1="https://youtube.com"
      url2="https://google.com"
      url3="https://facebook.com"
      url4="失败，"
      check_net /data/xray/节点/ping2.txt $node_name2 &
       pid2=$!
       wait $pid2
    fi
    
    wait $pid1
    

    if [[ $(awk -F'=' '/nodeswitch/{print $2; exit}'   /data/xray/xray设置.txt ) -eq 1 ]]; then          
          # 切换节点
        start_v2
        continue
    fi

    
done






# 此脚本将在late_start service 模式执行
