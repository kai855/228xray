cd /data/xray/节点
rm -r ping.txt ping1.txt ping2.txt

echo 测试节点中>>/data/xray/日志.txt



for file in /data/xray/节点/*.ini
do
    (# 使用 awk 获取 addr 的值
        
    addr=$(awk -F'addr="' '/addr/ {split($2, a, "\"") ; print a[1]}' $file)
    ip=${addr%:*}
    
    #打印出 ip 的值
    
    
    echo  $(basename $file .ini),$( ping -c 4 -w 1 $ip | awk -F'/' '/^round-trip|rtt/ {print $5}' ) >> ping.txt
        
    ) &
done



green='\033[0;32m'
plain='\033[0m'



proxy=$(awk -F'=' '/proxy/{print $2; exit}' /data/xray/xray设置.txt)

#国内节点匹配正则
node_pmatching="移动|电信|联通|China|空配"

wait

if [ "$proxy" = "1" ]; then
    while read -r line; do
        (
            if echo "$line" | grep -Eq "$node_pmatching"; then
                echo "$line" >> ping1.txt
            else
                echo "$line" >> ping2.txt
            fi
        ) &
    done < ping.txt
    wait
    
    #awk -F, '$2 >= 10' ping2.txt | sort -t, -k1n -k2n -o ping2.txt
    awk -F, '$1 >= 0' ping2.txt | sort -t, -k1n -k2n -o ping2.txt
else
    mv -f ping.txt ping1.txt
    echo ,未开启，999> ping2.txt
fi



#awk -F, '$2 >= 10' ping1.txt | sort -t, -k1n -k2n -o ping1.txt
awk -F, '$1 >= 0' ping1.txt | sort -t, -k1n -k2n -o ping1.txt


echo -e "${green}------测试完成------${plain}"
echo 节点测试完成>>/data/xray/日志.txt
