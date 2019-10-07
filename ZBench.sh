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
    read -e -p "Please Confirm Your Client IP:${OwnerIP} [y/n]: " ifOwnerIP
    if [[ ! ${ifOwnerIP} =~ ^[y,n]$ ]]; then
        echo "Input error! Please only input 'y' or 'n'"
    else
        break
    fi
done
if [[ ${ifOwnerIP} == "n" ]]; then
    while :; do echo
        read -e -p "Please Enter Your Client IP: " OwnerIP
        if [[ ! ${OwnerIP} ]]; then
            echo "Input error! Cannot be void!"
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

echo "Installing required packages, please wait..."

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

# Install Zping
if  [ ! -e '/tmp/zbench/ZPing.py' ]; then
    echo "Installing ZPing.py......"
    dir=$(pwd)
    cd /tmp/zbench/
    wget -N --no-check-certificate https://raw.githubusercontent.com/DesperadoJ/ZBench/master/ZPing.py > /dev/null 2>&1
    cd $dir
fi
chmod a+rx /tmp/zbench/ZPing.py

#"TraceRoute to Beijing Telecom"
/tmp/zbench/besttrace -q 1 -g en 113.59.224.1 > /tmp/zbench/bjt.txt 2>&1 &
#"TraceRoute to Beijing Unicom"
/tmp/zbench/besttrace -q 1 -g en 61.135.169.125 > /tmp/zbench/bju.txt 2>&1 &
#"TraceRoute to Beijing Mobile"
/tmp/zbench/besttrace -q 1 -g en 221.183.37.237 > /tmp/zbench/bjm.txt 2>&1 &
#"TraceRoute to Shanghai Telecom"
/tmp/zbench/besttrace -q 1 -g en 61.129.42.6 > /tmp/zbench/sht.txt 2>&1 &
#"TraceRoute to Shanghai Unicom"
/tmp/zbench/besttrace -q 1 -g en 210.22.80.1 > /tmp/zbench/shu.txt 2>&1 &
#"TraceRoute to Shanghai Mobile"
/tmp/zbench/besttrace -q 1 -g en 120.204.198.210 > /tmp/zbench/shm.txt 2>&1 &
#"TraceRoute to Guangdong Telecom"
/tmp/zbench/besttrace -q 1 -g en gd.189.cn > /tmp/zbench/gdt.txt 2>&1 &
#"TraceRoute to Guangdong Unicom"
/tmp/zbench/besttrace -q 1 -g en 221.5.88.88 > /tmp/zbench/gdu.txt 2>&1 &
#"TraceRoute to Guangdong Mobile"
/tmp/zbench/besttrace -q 1 -g en 211.136.192.6 > /tmp/zbench/gdm.txt 2>&1 &
#"TraceRoute to Owner's Network"
/tmp/zbench/besttrace -q 1 -g en ${OwnerIP} > /tmp/zbench/own.txt 2>&1 &

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
            printf "${YELLOW}%-25s${GREEN}%-18s${RED}%-20s${SKYBLUE}%-12s${PLAIN}\n" "${nodeName}" "${reupload}" "${REDownload}" "${relatency}"
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
                relatency=" timeout"
            fi
            local nodeName=$2
            printf "${YELLOW}%-25s${GREEN}%-18s${RED}%-20s${SKYBLUE}%-12s${PLAIN}\n" "${nodeName}" "${reupload}" "${REDownload}" "${relatency}"
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
    speed_test_cn '27594' 'Guangzhou CT'
    speed_test_cn '26352' 'Nanjing   CT'
    speed_test_cn '24011' 'Wuhan     CT'
    speed_test_cn '27377' 'Beijing   CT'
    speed_test_cn '26678' 'Guangzhou CU'
    speed_test_cn '24447' 'Shanghai  CU'
    speed_test_cn '5485' 'Wuhan     CU'
    speed_test_cn '5145' 'Beijing   CU'
    speed_test_cn '16171' 'Fuzhou    CM'
    speed_test_cn '25637' 'Shanghai  CM'
    speed_test_cn '26547' 'Wuhan     CM'
    speed_test_cn '25858' 'Beijing   CM'
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

echo -e "CPU model              : ${SKYBLUE}$cname${PLAIN}"
echo -e "Number of cores        : ${SKYBLUE}$cores${PLAIN}"
echo -e "CPU frequency          : ${SKYBLUE}$freq MHz${PLAIN}"
echo -e "Total size of Disk     : ${SKYBLUE}$disk_total_size GB ($disk_used_size GB Used)${PLAIN}"
echo -e "Total amount of Mem    : ${SKYBLUE}$tram MB ($uram MB Used)${PLAIN}"
echo -e "Total amount of Swap   : ${SKYBLUE}$swap MB ($uswap MB Used)${PLAIN}"
echo -e "System uptime          : ${SKYBLUE}$up${PLAIN}"
echo -e "Load average           : ${SKYBLUE}$load${PLAIN}"
echo -e "OS                     : ${SKYBLUE}$opsy${PLAIN}"
echo -e "Arch                   : ${SKYBLUE}$arch ($lbit Bit)${PLAIN}"
echo -e "Kernel                 : ${SKYBLUE}$kern${PLAIN}"
echo -e "TCP congestion control : ${SKYBLUE}$tcpctrl${PLAIN}"
echo -ne "Virt                   : "
virtua=$(virt-what) 2>/dev/null
if [[ ${virtua} ]]; then
    echo -e "${SKYBLUE}$virtua${PLAIN}"
else
    virtua="No Virt"
    echo -e "${SKYBLUE}No Virt${PLAIN}"
fi
next

io1=$( io_test )
echo -e "I/O speed (1st run)    : ${YELLOW}$io1${PLAIN}"
io2=$( io_test )
echo -e "I/O speed (2nd run)    : ${YELLOW}$io2${PLAIN}"
io3=$( io_test )
echo -e "I/O speed (3rd run)    : ${YELLOW}$io3${PLAIN}"
next

##Record All Test data
touch /tmp/zbench/info.txt
echo $cname >> /tmp/zbench/info.txt
echo $cores >> /tmp/zbench/info.txt
echo $freq MHz >> /tmp/zbench/info.txt
echo "$disk_total_size GB ($disk_used_size GB used)">> /tmp/zbench/info.txt
echo "$tram MB ($uram MB used)">> /tmp/zbench/info.txt
echo "$swap MB ($uswap MB used)" >> /tmp/zbench/info.txt
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

printf "%-26s%-18s%-20s%-12s\n" "Node Name" "IP Address" "Download Speed" "Latency"
speed && next
printf "%-26s%-18s%-20s%-12s\n" "Node Name" "Upload Speed" "Download Speed" "Latency"
speed_cn && next
python /tmp/zbench/ZPing.py
next

wget -N --no-check-certificate https://raw.githubusercontent.com/DesperadoJ/ZBench/master/Generate.py >> /dev/null 2>&1
python Generate.py && cp /root/report.html /tmp/report/index.html
echo "Your bench report is saved to /root/report.html"

# If use simple http server
while :; do echo
    read -e -p "Do you want to check your Test Report? [y/n]: " ifreport
    if [[ ! $ifreport =~ ^[y,n]$ ]]; then
        echo "Input error! Please only input 'y' or 'n'"
    else
        break
    fi
done
if [[ $ifreport == 'y' ]];then
    echo ""
    myip=`curl -m 10 -s http://members.3322.org/dyndns/getip`
    echo "Visit http://${myip}:8001/index.html to see your report，Press Ctrl + C to exit."
    cd /tmp/report
    iptables -I INPUT -p tcp -m state --state NEW -m tcp --dport 8001 -j ACCEPT
    python -m SimpleHTTPServer 8001
fi
