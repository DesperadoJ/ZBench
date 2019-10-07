#!/usr/bin/env bash
#
# URL:https://github.com/DesperadoJ/ZBench

# Check if user is root
[ $(id -u) != "0" ] && { echo "${CFAILURE}Error: You must be root to run this script${CEND}"; exit 1; }

# Check if wget installed
if  [ ! -e '/usr/bin/wget' ]; then
    echo "Error: wget command not found. You must be install wget command at first."
    exit 1
fi

# Get IP
OwnerIP=$(who am i | awk '{print $NF}' | sed -e 's/[()]//g')
while :; do echo
    read -e -p "请确认你所在地的IP:${OwnerIP} [y/n]: " ifOwnerIP
    if [[ ! ${ifOwnerIP} =~ ^[y,n]$ ]]; then
        echo "输入错误! 请确保你输入的是 'y' 或者 'n'"
    else
        break
    fi
done
if [[ ${ifOwnerIP} == "n" ]]; then
    while :; do echo
        read -e -p "请输入你所在地的IP: " OwnerIP
        if [[ ! ${OwnerIP} ]]; then
            echo "输入错误!IP地址不能为空！"
        else
            break
        fi
    done
fi

# Check release
if [ -f /etc/redhat-release ]; then
    release="centos"
elif cat /etc/issue | grep -Eqi "debian"; then
    release="debian"
elif cat /etc/issue | grep -Eqi "ubuntu"; then
    release="ubuntu"
elif cat /etc/issue | grep -Eqi "centos|red hat|redhat"; then
    release="centos"
elif cat /proc/version | grep -Eqi "debian"; then
    release="debian"
elif cat /proc/version | grep -Eqi "ubuntu"; then
    release="ubuntu"
elif cat /proc/version | grep -Eqi "centos|red hat|redhat"; then
    release="centos"
fi

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
SKYBLUE='\033[0;36m'
PLAIN='\033[0m'

rm -rf /tmp/{zbench,report} && mkdir /tmp/{zbench,report}

echo "正在安装必要的依赖，请耐心等待..."

# Install Virt-what
if  [ ! -e '/usr/sbin/virt-what' ]; then
    echo "Installing Virt-What......"
    if [ "${release}" == "centos" ]; then
        yum -y install virt-what > /dev/null 2>&1
    else
        apt-get update > /dev/null 2>&1
        apt-get -y install virt-what > /dev/null 2>&1
    fi
fi

# Install curl
echo "Installing curl......"
if [ "${release}" == "centos" ]; then
    yum -y install curl > /dev/null 2>&1
else
    apt-get -y install curl > /dev/null 2>&1
fi

# Install Besttrace
if  [ ! -e '/tmp/zbench/besttrace' ]; then
    echo "Installing Besttrace......"
    dir=$(pwd)
    cd /tmp/zbench/
    wget  -N --no-check-certificate https://raw.githubusercontent.com/DesperadoJ/ZBench/master/besttrace > /dev/null 2>&1
    cd $dir
fi
chmod a+rx /tmp/zbench/besttrace

# Check Python
if  [ ! -e '/usr/bin/python' ]; then
    echo "Installing Python......"
    if [ "${release}" == "centos" ]; then
            yum update > /dev/null 2>&1
            yum -y install python
        else
            apt-get update > /dev/null 2>&1
            apt-get -y install python
    fi
fi

# Install Speedtest
if  [ ! -e '/tmp/zbench/speedtest.py' ]; then
    echo "Installing SpeedTest......"
    dir=$(pwd)
    cd /tmp/zbench/
    wget -N --no-check-certificate https://raw.github.com/sivel/speedtest-cli/master/speedtest.py > /dev/null 2>&1
    cd $dir
fi
chmod a+rx /tmp/zbench/speedtest.py

# Install Zping-CN
if  [ ! -e '/tmp/zbench/ZPing-CN.py' ]; then
    echo "Installing ZPing-CN.py......"
    dir=$(pwd)
    cd /tmp/zbench/
    wget -N --no-check-certificate https://raw.githubusercontent.com/DesperadoJ/ZBench/master/ZPing-CN.py > /dev/null 2>&1
    cd $dir
fi
chmod a+rx /tmp/zbench/ZPing-CN.py

#"TraceRoute to Beijing Telecom"
/tmp/zbench/besttrace -q 1 -g cn 113.59.224.1 > /tmp/zbench/bjt.txt 2>&1 &
#"TraceRoute to Beijing Unicom"
/tmp/zbench/besttrace -q 1 -g cn 61.135.169.125 > /tmp/zbench/bju.txt 2>&1 &
#"TraceRoute to Beijing Mobile"
/tmp/zbench/besttrace -q 1 -g cn 221.183.37.237 > /tmp/zbench/bjm.txt 2>&1 &
#"TraceRoute to Shanghai Telecom"
/tmp/zbench/besttrace -q 1 -g cn 61.129.42.6 > /tmp/zbench/sht.txt 2>&1 &
#"TraceRoute to Shanghai Unicom"
/tmp/zbench/besttrace -q 1 -g cn 210.22.80.1 > /tmp/zbench/shu.txt 2>&1 &
#"TraceRoute to Shanghai Mobile"
/tmp/zbench/besttrace -q 1 -g cn 120.204.198.210 > /tmp/zbench/shm.txt 2>&1 &
#"TraceRoute to Guangdong Telecom"
/tmp/zbench/besttrace -q 1 -g cn gd.189.cn > /tmp/zbench/gdt.txt 2>&1 &
#"TraceRoute to Guangdong Unicom"
/tmp/zbench/besttrace -q 1 -g cn 221.5.88.88 > /tmp/zbench/gdu.txt 2>&1 &
#"TraceRoute to Guangdong Mobile"
/tmp/zbench/besttrace -q 1 -g cn 211.136.192.6 > /tmp/zbench/gdm.txt 2>&1 &
#"TraceRoute to Owner's Network"
/tmp/zbench/besttrace -q 1 -g cn ${OwnerIP} > /tmp/zbench/own.txt 2>&1 &

get_opsy() {
    [ -f /etc/redhat-release ] && awk '{print ($1,$3~/^[0-9]/?$3:$4)}' /etc/redhat-release && return
    [ -f /etc/os-release ] && awk -F'[= "]' '/PRETTY_NAME/{print $3,$4,$5}' /etc/os-release && return
    [ -f /etc/lsb-release ] && awk -F'[="]+' '/DESCRIPTION/{print $2}' /etc/lsb-release && return
}

next() {
    printf "%-74s\n" "-" | sed 's/\s/-/g'
}

speed_test() {
    local speedtest=$(wget -4O /dev/null -T300 $1 2>&1 | awk '/\/dev\/null/ {speed=$3 $4} END {gsub(/\(|\)/,"",speed); print speed}')
    local ipaddress=$(ping -c1 -n `awk -F'/' '{print $3}' <<< $1` | awk -F'[()]' '{print $2;exit}')
    local nodeName=$2
    local latency=$(ping $ipaddress -c 3 | grep avg | awk -F / '{print $5}')" ms"
    printf "${YELLOW}%-26s${GREEN}%-18s${RED}%-20s${SKYBLUE}%-12s${PLAIN}\n" "${nodeName}" "${ipaddress}" "${speedtest}" "${latency}"

    #Record Speed Data
    echo ${ipaddress} >> /tmp/zbench/speed.txt
    echo ${speedtest} >> /tmp/zbench/speed.txt
    echo ${latency} >> /tmp/zbench/speed.txt
}

speed() {
    touch /tmp/zbench/speed.txt
    speed_test 'http://cachefly.cachefly.net/100mb.test' 'CacheFly'
    speed_test 'http://speedtest.tokyo2.linode.com/100MB-tokyo2.bin' 'Linode, Tokyo, JP'
    speed_test 'http://speedtest.singapore.linode.com/100MB-singapore.bin' 'Linode, Singapore, SG'
    speed_test 'http://speedtest.fremont.linode.com/100MB-fremont.bin' 'Linode, Fremont, CA'
    speed_test 'http://speedtest.london.linode.com/100MB-london.bin' 'Linode, London, UK'
    speed_test 'http://speedtest.frankfurt.linode.com/100MB-frankfurt.bin' 'Linode, Frankfurt, DE'
    speed_test 'http://speedtest.hkg02.softlayer.com/downloads/test100.zip' 'Softlayer, HongKong, CN'
    speed_test 'http://speedtest.sng01.softlayer.com/downloads/test100.zip' 'Softlayer, Singapore, SG'
    speed_test 'http://speedtest.dal05.softlayer.com/downloads/test100.zip' 'Softlayer, Dallas, TX'
    speed_test 'http://speedtest.sea01.softlayer.com/downloads/test100.zip' 'Softlayer, Seattle, WA'
    speed_test 'http://speedtest.fra02.softlayer.com/downloads/test100.zip' 'Softlayer, Frankfurt, DE'
}

speed_test_cn(){
    if [[ $1 == '' ]]; then
        temp=$(python /tmp/zbench/speedtest.py --share 2>&1)
        is_down=$(echo "$temp" | grep 'Download')
        if [[ ${is_down} ]]; then
            local REDownload=$(echo "$temp" | awk -F ':' '/Download/{print $2}')
            local reupload=$(echo "$temp" | awk -F ':' '/Upload/{print $2}')
            local relatency=$(echo "$temp" | awk -F ':' '/Hosted/{print $2}')
            local nodeName=$2
            printf "${YELLOW}%-29s${GREEN}%-18s${RED}%-20s${SKYBLUE}%-12s${PLAIN}\n" "${nodeName}" "${reupload}" "${REDownload}" "${relatency}"
        else
            local cerror="ERROR"
        fi
    else
        temp=$(python /tmp/zbench/speedtest.py --server $1 --share 2>&1)
        is_down=$(echo "$temp" | grep 'Download')
        if [[ ${is_down} ]]; then
            local REDownload=$(echo "$temp" | awk -F ':' '/Download/{print $2}')
            local reupload=$(echo "$temp" | awk -F ':' '/Upload/{print $2}')
            local relatency=$(echo "$temp" | awk -F ':' '/Hosted/{print $2}')
            temp=$(echo "$relatency" | awk -F '.' '{print $1}')
            if [[ ${temp} -gt 1000 ]]; then
                relatency=" 超时"
            fi
            local nodeName=$2
            printf "${YELLOW}%-29s${GREEN}%-18s${RED}%-20s${SKYBLUE}%-12s${PLAIN}\n" "${nodeName}" "${reupload}" "${REDownload}" "${relatency}"
        else
            local cerror="ERROR"
        fi
    fi

    #Record Speed_cn Data
    echo ${reupload} >> /tmp/zbench/speed_cn.txt
    echo ${REDownload} >> /tmp/zbench/speed_cn.txt
    echo ${relatency} >> /tmp/zbench/speed_cn.txt
}

speed_cn() {
    touch /tmp/zbench/speed_cn.txt
    speed_test_cn '27594' '广州电信'
    speed_test_cn '26352' '南京电信'
    speed_test_cn '24011' '武汉电信'
    speed_test_cn '27377' '北京电信'
    speed_test_cn '26678' '广州联通'
    speed_test_cn '24447' '上海联通'
    speed_test_cn '5485' '武汉联通'
    speed_test_cn '5145' '北京联通'
    speed_test_cn '16171' '福州移动'
    speed_test_cn '25637' '上海移动'
    speed_test_cn '26547' '武汉移动'
    speed_test_cn '25858' '北京移动'
}

io_test() {
    (LANG=C dd if=/dev/zero of=test_$$ bs=64k count=16k conv=fdatasync && rm -f test_$$ ) 2>&1 | awk -F, '{io=$NF} END { print io}' | sed 's/^[ \t]*//;s/[ \t]*$//'
}

calc_disk() {
    local total_size=0
    local array=$@
    for size in ${array[@]}
    do
        [ "${size}" == "0" ] && size_t=0 || size_t=`echo ${size:0:${#size}-1}`
        [ "`echo ${size:(-1)}`" == "K" ] && size=0
        [ "`echo ${size:(-1)}`" == "M" ] && size=$( awk 'BEGIN{printf "%.1f", '$size_t' / 1024}' )
        [ "`echo ${size:(-1)}`" == "T" ] && size=$( awk 'BEGIN{printf "%.1f", '$size_t' * 1024}' )
        [ "`echo ${size:(-1)}`" == "G" ] && size=${size_t}
        total_size=$( awk 'BEGIN{printf "%.1f", '$total_size' + '$size'}' )
    done
    echo ${total_size}
}


cname=$( awk -F: '/model name/ {name=$2} END {print name}' /proc/cpuinfo | sed 's/^[ \t]*//;s/[ \t]*$//' )
cores=$( awk -F: '/model name/ {core++} END {print core}' /proc/cpuinfo )
freq=$( awk -F: '/cpu MHz/ {freq=$2} END {print freq}' /proc/cpuinfo | sed 's/^[ \t]*//;s/[ \t]*$//' )
tram=$( free -m | awk '/Mem/ {print $2}' )
uram=$( free -m | awk '/Mem/ {print $3}' )
swap=$( free -m | awk '/Swap/ {print $2}' )
uswap=$( free -m | awk '/Swap/ {print $3}' )
up=$( awk '{a=$1/86400;b=($1%86400)/3600;c=($1%3600)/60} {printf("%d days, %d hour %d min\n",a,b,c)}' /proc/uptime )
load=$( w | head -1 | awk -F'load average:' '{print $2}' | sed 's/^[ \t]*//;s/[ \t]*$//' )
opsy=$( get_opsy )
arch=$( uname -m )
lbit=$( getconf LONG_BIT )
kern=$( uname -r )
#ipv6=$( wget -qO- -t1 -T2 ipv6.icanhazip.com )
disk_size1=($( LANG=C df -hPl | grep -wvE '\-|none|tmpfs|devtmpfs|by-uuid|chroot|Filesystem' | awk '{print $2}' ))
disk_size2=($( LANG=C df -hPl | grep -wvE '\-|none|tmpfs|devtmpfs|by-uuid|chroot|Filesystem' | awk '{print $3}' ))
disk_total_size=$( calc_disk ${disk_size1[@]} )
disk_used_size=$( calc_disk ${disk_size2[@]} )
tcpctrl=$( sysctl net.ipv4.tcp_congestion_control | awk -F ' ' '{print $3}' )
clear
next

echo -e "CPU 型号               : ${SKYBLUE}$cname${PLAIN}"
echo -e "CPU 核心数             : ${SKYBLUE}$cores${PLAIN}"
echo -e "CPU 频率               : ${SKYBLUE}$freq MHz${PLAIN}"
echo -e "总硬盘大小             : ${SKYBLUE}$disk_total_size GB ($disk_used_size GB 已使用)${PLAIN}"
echo -e "总内存大小             : ${SKYBLUE}$tram MB ($uram MB 已使用)${PLAIN}"
echo -e "SWAP大小               : ${SKYBLUE}$swap MB ($uswap MB 已使用)${PLAIN}"
echo -e "开机时长               : ${SKYBLUE}$up${PLAIN}"
echo -e "系统负载               : ${SKYBLUE}$load${PLAIN}"
echo -e "系统                   : ${SKYBLUE}$opsy${PLAIN}"
echo -e "架构                   : ${SKYBLUE}$arch ($lbit 位)${PLAIN}"
echo -e "内核                   : ${SKYBLUE}$kern${PLAIN}"
echo -e "TCP拥塞控制            : ${SKYBLUE}$tcpctrl${PLAIN}"
echo -ne "虚拟化平台             : "
virtua=$(virt-what) 2>/dev/null
if [[ ${virtua} ]]; then
    echo -e "${SKYBLUE}$virtua${PLAIN}"
else
    virtua="无虚拟化"
    echo -e "${SKYBLUE}No Virt${PLAIN}"
fi
next

io1=$( io_test )
echo -e "硬盘I/O (第一次测试)   : ${YELLOW}$io1${PLAIN}"
io2=$( io_test )
echo -e "硬盘I/O (第二次测试)   : ${YELLOW}$io2${PLAIN}"
io3=$( io_test )
echo -e "硬盘I/O (第三次测试)   : ${YELLOW}$io3${PLAIN}"
next

##Record All Test data
touch /tmp/zbench/info.txt
echo $cname >> /tmp/zbench/info.txt
echo $cores >> /tmp/zbench/info.txt
echo $freq MHz >> /tmp/zbench/info.txt
echo "$disk_total_size GB ($disk_used_size GB 已使用)">> /tmp/zbench/info.txt
echo "$tram MB ($uram MB 已使用)">> /tmp/zbench/info.txt
echo "$swap MB ($uswap MB 已使用)" >> /tmp/zbench/info.txt
echo $up >> /tmp/zbench/info.txt
echo $load >> /tmp/zbench/info.txt
echo $opsy >> /tmp/zbench/info.txt
echo "$arch ($lbit 位) ">> /tmp/zbench/info.txt
echo $kern >> /tmp/zbench/info.txt
echo $tcpctrl >> /tmp/zbench/info.txt
echo $virtua >> /tmp/zbench/info.txt
echo $io1 >> /tmp/zbench/info.txt
echo $io2 >> /tmp/zbench/info.txt
echo $io3 >> /tmp/zbench/info.txt

printf "%-30s%-20s%-24s%-12s\n" "节点名称" "IP地址" "下载速度" "延迟"
speed && next
printf "%-30s%-22s%-24s%-12s\n" "节点名称" "上传速度" "下载速度" "延迟"
speed_cn && next
python /tmp/zbench/ZPing-CN.py
next

wget -N --no-check-certificate https://raw.githubusercontent.com/DesperadoJ/ZBench/master/Generate.py >> /dev/null 2>&1
python Generate.py && cp /root/report.html /tmp/report/index.html
echo "您的测评报告已保存在 /root/report.html"

# If use simple http server
while :; do echo
    read -e -p "你想现在查看您的测评报告吗? [y/n]: " ifreport
    if [[ ! $ifreport =~ ^[y,n]$ ]]; then
        echo "输入错误! 请确保你输入的是 'y' 或者 'n'"
    else
        break
    fi
done
if [[ $ifreport == 'y' ]];then
    echo ""
    myip=`curl -m 10 -s http://members.3322.org/dyndns/getip`
    echo "访问 http://${myip}:8001/index.html 查看您的测试报告，按 Ctrl + C 退出"
    cd /tmp/report
    iptables -I INPUT -p tcp -m state --state NEW -m tcp --dport 8001 -j ACCEPT
    python -m SimpleHTTPServer 8001
fi
