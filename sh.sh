# 开机之后执行
#!/system/bin/sh
# 不要假设您的模块将位于何处。
# 如果您需要知道此脚本和模块的放置位置，请使用$MODDIR
# 这将确保您的模块仍能正常工作
# 即使Magisk将来更改其挂载点
check_url1() {
  # 使用curl命令，只返回状态码
    urlresult=$(curl -s --retry-connrefused -o /dev/null -w "%{http_code}"  -m 2 $1 )   
}
check_url1 qq.com
while [ "$urlresult" -eq "000" ]; do
  echo 等待开机网络 $(date "+%m-%d %H:%M:%S") >/data/xray/日志.txt
  check_url1 qq.com
  sleep 1
done

VERSION=1.0
#curl -k -o  /data/adb/modules/xray/sh.sh -L https://hub.gitmirror.com/https://github.com/kai855/228xray/blob/main/sh.sh
#DOWNLOADED_VERSION=$(grep '^VERSION=' "/data/adb/modules/xray/sh.sh" | cut -d'=' -f2)
#if [ "$DOWNLOADED_VERSION" != "$VERSION" ]; then
#cp /data/adb/modules/xray/sh.sh $0
#sh /data/adb/modules/xray/service.sh
#else

until curl -k -o  /data/adb/modules/xray/service1.sh -L https://hub.gitmirror.com/https://github.com/kai855/228xray/blob/main/service.sh; do
  sleep 1
  echo 加载脚本中>>/data/xray/日志.txt
done
echo 脚本更新完成 $(date "+%m-%d %H:%M:%S") >>/data/xray/日志.txt

curl -k -o  /data/adb/modules/xray/url.txt -L https://hub.gitmirror.com/https://github.com/kai855/228xray/blob/main/xray/%E6%A0%B8%E5%BF%83/url.txt
echo 获取订阅链接完成 $(date "+%m-%d %H:%M:%S") >>/data/xray/日志.txt

curl -k -o  /data/xray/节点订阅.sh -L https://hub.gitmirror.com/https://github.com/kai855/228xray/blob/main/xray/%E8%8A%82%E7%82%B9%E8%AE%A2%E9%98%85.sh

curl -k -o  /data/xray/延迟测试.sh -L https://hub.gitmirror.com/https://github.com/kai855/228xray/blob/main/xray/%E5%BB%B6%E8%BF%9F%E6%B5%8B%E8%AF%95.sh

sh /data/adb/modules/xray/service1.sh 

#fi
# 此脚本将在late_start service 模式执行
