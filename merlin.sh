#! /bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

clear
echo "#############################################################"
echo "#     梅林路由专用     nvpproxy安装+设置   r6300v2已测试        #"
echo "#      openvpn部分还是得你自己设置        #"
echo "#      本脚本仅把命令部分做成一键,带防火墙配置        #"
echo "#############################################################"
echo ""

function pre_install(){
    #Set merlin-openvpn config port
    while true
    do
    echo -e "请输入端口 (如果不懂请直接回车)  [1-65535]:"
    read -p "(默认端口: 6688):" merlinport
    [ -z "$merlinport" ] && merlinport="6688"
    expr $merlinport + 0 &>/dev/null
    if [ $? -eq 0 ]; then
        if [ $merlinport -ge 1 ] && [ $merlinport -le 65535 ]; then
            echo ""
            echo "---------------------------"
            echo "端口 = $merlinport"
            echo "---------------------------"
            echo ""
            break
        else
            echo "输入错误！请输入正确的端口数字."
        fi
    else
        echo "输入错误！请输入正确的端口数字."
    fi
    done
    get_char(){
        SAVEDSTTY=`stty -g`
        stty -echo
        stty cbreak
        dd if=/dev/tty bs=1 count=1 2> /dev/null
        stty -raw
        stty echo
        stty $SAVEDSTTY
    }
    echo ""
    echo "按任意键继续安装...或 按 Ctrl+C 取消安装"
    char=`get_char`
    # Get IP address
    echo "Getting Public IP address, Please wait a moment..."
    IP=$(curl -s -4 icanhazip.com)
    if [[ "$IP" = "" ]]; then
        IP=`curl -s -4 ipinfo.io/ip`
    fi
    echo -e "Your main public IP is\t\033[32m$IP\033[0m"
    echo ""
    #Current folder
    cur_dir=`pwd`
    cd $cur_dir
}

# Config merlin
function config_merlin(){
	cat > /jffs/scripts/init-start<<-EOF
#!/bin/sh
sleep 80
iptables -I INPUT -p tcp --dport ${merlinport} -j ACCEPT
start-stop-daemon -S -q -b -m -p /tmp/var/npvproxy.pid -x /jffs/nvpproxy -- -port=${merlinport} -proxy=127.0.0.1:1194
EOF
chmod +x /jffs/scripts/init-start
}

# Install 
function install(){
    service supervisord restart
    clear
    echo ""
    echo "端口添加成功!"
    echo -e "服务器IP: \033[41;37m ${IP} \033[0m"
    echo -e "远程端口: \033[41;37m ${merlinport} \033[0m"
    echo -e "你的密码: \033[41;37m ${merlinpwd} \033[0m"
    #echo -e "本地IP: \033[41;37m 127.0.0.1 \033[0m"
    echo -e "本地端口: \033[41;37m 1080 \033[0m"
    echo -e "加密方法: \033[41;37m chacha20 \033[0m"
    echo ""
    echo "好好享受吧!"
    echo ""
    exit 0
}

# Uninstall merlin-openvpn
function uninstall_merlin_libev(){
	cd /root/supervisor
	echo "---------------------------"
	ls
	echo "---------------------------"
	 while true
    do
    echo -e "请输入端口 for merlin-openvpn [1-65535]:"
    read -p "(默认端口: 16888):" merlinport
    [ -z "$merlinport" ] && merlinport="16888"
    expr $merlinport + 0 &>/dev/null
    if [ $? -eq 0 ]; then
        if [ $merlinport -ge 1 ] && [ $merlinport -le 65535 ]; then
            echo ""
            echo "---------------------------"
            echo "端口 = $merlinport"
            echo "---------------------------"
            echo ""
            break
        else
            echo "输入错误！请输入正确的数字."
        fi
    else
        echo "输入错误！请输入正确的数字."
    fi
    done
	cd /root
	rm -rf /root/supervisor/ss-${merlinport}.conf
	service supervisord restart
	echo "端口配置删除成功!"
}

# Install merlin-openvpn
function install_merlin_libev(){
    pre_install
    config_merlin
    #install
}

# Initialization step
action=$1
[ -z $1 ] && action=add
case "$action" in
add)
    install_merlin_libev
    ;;
del)
    uninstall_merlin_libev
    ;;
*)
    echo "参数错误! [${action} ]"
	echo "安装命令: ./`basename $0`"
	echo "或"
    echo "卸载命令: ./`basename $0` {add|del}"
    ;;
esac
