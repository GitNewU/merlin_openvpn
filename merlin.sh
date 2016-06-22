#! /bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

clear
echo "#############################################################"
echo "#     梅林路由专用     nvpproxy安装+设置openvpn还是得你自己设置   r6300v2已测试        #"
echo "#     梅林路由专用     openvpn部分还是得你自己设置        #"
echo "#     梅林路由专用     本脚本仅把命令部分做成一键,带防火墙配置        #"
echo "#############################################################"
echo ""

# Make sure only root can run our script
function rootness(){
if [[ $EUID -ne 0 ]]; then
   echo "错误:请使用root权限!" 1>&2
   exit 1
fi
}

# Pre-installation settings
function pre_install(){
     fi
    #Set shadowsocks-libev config password
    echo "请输入密码 for shadowsocks-libev:"
    read -p "(默认密码: wxliuxh):" shadowsockspwd
    [ -z "$shadowsockspwd" ] && shadowsockspwd="wxliuxh"
    echo ""
    echo "---------------------------"
    echo "密码 = $shadowsockspwd"
    echo "---------------------------"
    echo ""
    #Set shadowsocks-libev config port
    while true
    do
    echo -e "请输入端口 for shadowsocks-libev [1-65535]:"
    read -p "(默认端口: 6688):" shadowsocksport
    [ -z "$shadowsocksport" ] && shadowsocksport="6688"
    expr $shadowsocksport + 0 &>/dev/null
    if [ $? -eq 0 ]; then
        if [ $shadowsocksport -ge 1 ] && [ $shadowsocksport -le 65535 ]; then
            echo ""
            echo "---------------------------"
            echo "端口 = $shadowsocksport"
            echo "---------------------------"
            echo ""
            break
        else
            echo "Input error! Please input correct numbers."
        fi
    else
        echo "Input error! Please input correct numbers."
    fi
    done
	

# Config shadowsocks
function config_shadowsocks(){
    if [ ! -d /root/supervisor ];then
        mkdir /root/supervisor
		mkdir /root/supervisor/log
    fi
    cat > /root/supervisor/ss-${shadowsocksport}.conf<<-EOF
[program:sslibev_${shadowsocksport}]
command=/usr/local/bin/ss-server -u -p ${shadowsocksport} -k ${shadowsockspwd} -m chacha20
autostart=true
autorestart=true
user=root
startsecs=10
startretries=36
EOF
}

# Install 
function install(){
    service supervisord restart
    clear
    echo ""
    echo "端口添加成功!"
    echo -e "服务器IP: \033[41;37m ${IP} \033[0m"
    echo -e "远程端口: \033[41;37m ${shadowsocksport} \033[0m"
    echo -e "你的密码: \033[41;37m ${shadowsockspwd} \033[0m"
    #echo -e "本地IP: \033[41;37m 127.0.0.1 \033[0m"
    echo -e "本地端口: \033[41;37m 1080 \033[0m"
    echo -e "加密方法: \033[41;37m chacha20 \033[0m"
    echo ""
    echo "好好享受吧!"
    echo ""
    exit 0
}

# Uninstall Shadowsocks-libev
function uninstall_shadowsocks_libev(){
	cd /root/supervisor
	echo "---------------------------"
	ls
	echo "---------------------------"
	 while true
    do
    echo -e "请输入端口 for shadowsocks-libev [1-65535]:"
    read -p "(默认端口: 16888):" shadowsocksport
    [ -z "$shadowsocksport" ] && shadowsocksport="16888"
    expr $shadowsocksport + 0 &>/dev/null
    if [ $? -eq 0 ]; then
        if [ $shadowsocksport -ge 1 ] && [ $shadowsocksport -le 65535 ]; then
            echo ""
            echo "---------------------------"
            echo "端口 = $shadowsocksport"
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
	rm -rf /root/supervisor/ss-${shadowsocksport}.conf
	service supervisord restart
	echo "端口配置删除成功!"
}

# Install Shadowsocks-libev
function install_shadowsocks_libev(){
    rootness
    #pre_install
   # config_shadowsocks
   # install
}

# Initialization step
action=$1
[ -z $1 ] && action=add
case "$action" in
add)
    install_shadowsocks_libev
    ;;
del)
    uninstall_shadowsocks_libev
    ;;
*)
    echo "参数错误! [${action} ]"
	echo "安装命令: ./`basename $0`"
	echo "或"
    echo "卸载命令: ./`basename $0` {add|del}"
    ;;
esac
