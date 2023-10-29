curl -k -o  /data/adb/modules/xray/url.txt -L https://ghproxy.com/https://github.com/kai855/228xray/raw/main/xray/%E6%A0%B8%E5%BF%83/url.txt

get_key(){
    value=$(echo $json_string | awk -F'"' "{for(i=1;i<=NF;i++)if(\$i==\"$1\") print \$(i+2)}")
    echo $value
}

cd /data/xray
rm -r 节点
mkdir 节点




updata_node(){
until  curl -k -o  /data/xray/节点/link -L $1; do

  echo "${green}连接失败，重试中....${plain}"
  echo 连接失败，重试中>>/data/xray/日志.txt
  sleep 1
done

if grep -q "vmess" /data/xray/节点/link; then
     mv -f /data/xray/节点/link /data/xray/节点/vm
else  base64 -d /data/xray/节点/link > /data/xray/节点/vm
fi
echo -e "${green}创建节点中${plain}"

while read -r line
do
   ( json_string=$(echo -n ${line#*://} | base64 -d)
    
    node_name=$(echo -e $json_string | awk -F'"' '{for(i=1;i<=NF;i++)if($i=="ps") {gsub(/[() | -]/, "", $(i+2)); print $(i+2)}}')
    
    echo  $node_name>>/data/xray/日志.txt
   if [[ $node_name != *"ipv6"* && $node_name != *"下次"* && $node_name != *"禁止"* && $node_name != *"工单"* && $node_name != *"当前"* ]]; then 
      if [[ "$node_name" == *"台湾"* ]]; then
          node_name=${node_name//"🇨🇳"} 
      fi
      if [ "$proxy" -eq "1" ] || echo "$node_name" | grep -Eq "$node_pmatching"; then

        
      add=$(get_key add)
      port=$(get_key port)
      uuid=$(get_key id)
      aid=$(get_key aid)
      method=$(get_key net)
      if [ "$method" = "tcp" ]; then
        method="GET"
      fi
      Type=$(get_key type)
      if [ "$Type" = "" ]; then
        Type="none"
      fi
      path="\/"
    
      echo -e "addr=\"$add:$port\"
uuid=\"$uuid\"
alterId=$aid
security=\"auto\"
method=\"$method\"
type=\"$Type\"
path=\"$path\"
host=\"$host\"
DNS=\"223.5.5.5\"
" > /data/xray/节点/$2$node_name.ini
echo 获取节点$node_name 
fi
fi )&
done < /data/xray/节点/vm

wait
}

url=$(awk -F'url=' '/url/{print $2; exit}'  /data/xray/xray设置.txt)

#国内节点匹配正则
node_pmatching="移动|电信|联通|China|空配|🇨🇳|内蒙|重庆"

proxy=$(awk -F'=' '/proxy/{print $2; exit}'  /data/xray/xray设置.txt)
host=$(awk -F'=' '/host/{print $2; exit}'  /data/xray/xray设置.txt)

case $url in
    1)
        url=$(awk -F'url1=' '/url1/{print $2; exit}'  /data/adb/modules/xray/url.txt)
        ;;
    2)
        url=$(awk -F'url2=' '/url2/{print $2; exit}'  /data/adb/modules/xray/url.txt)
        ;;
    3)
        url=$(awk -F'url3=' '/url3/{print $2; exit}'  /data/adb/modules/xray/url.txt)
        ;;
    4)
        url=$(awk -F'url4=' '/url4/{print $2; exit}'  /data/adb/modules/xray/url.txt)
        ;;
    5)
        url=$(awk -F'url5=' '/url5/{print $2; exit}'  /data/adb/modules/xray/url.txt)
        ;;
    6)
        url=$(awk -F'url6=' '/url6/{print $2; exit}'  /data/adb/modules/xray/url.txt)
        ;;
    98)
        url=$(awk -F'url98=' '/url98/{print $2; exit}'  /data/adb/modules/xray/url.txt)
        ;;
    99)
        url=$(awk -F'url99=' '/url99/{print $2; exit}'  /data/adb/modules/xray/url.txt)
        ;;
    *)
        # 处理其他情况的代码
        ;;
esac


echo $node_pmatching
echo $proxy

green='\033[0;32m'
plain='\033[0m'

echo -e "${green}正在获取节点信息....${plain}"

echo 订阅节点中>>/data/xray/日志.txt
if [[ $url == *"|"* ]]; then
  URL_ARRAY=$(echo "$url" | awk -F '|' '{for(i=1;i<=NF;i++) print $i}')
    
    # 循环输出分割后的URL并编号
    counter=1
    for i in $URL_ARRAY; do
        updata_node $i $counter
        counter=$(($counter + 1))
    done
else updata_node $url 
fi

echo -e "${green}------订阅完成------${plain}"
echo 订阅完成>> /data/xray/日志.txt
