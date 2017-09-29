#!/bin/sh
#
# Copyright (C) 2015 OpenWrt-dist
# Copyright (C) 2016 fw867 <ffkykzs@gmail.com>
#
# This is free software, licensed under the GNU General Public License v3.
# See /LICENSE for more information.
#

policyenable=`uci get mwan3.base.enable` 
telecom=`uci get mwan3.base.telecom 2>/dev/null` 
unicom=`uci get mwan3.base.unicom 2>/dev/null` 
mobile=`uci get mwan3.base.mobile 2>/dev/null` 
cernet=`uci get mwan3.base.cernet 2>/dev/null` 
cnn=`uci get mwan3.base.cnn 2>/dev/null` 
foreign=`uci get mwan3.base.foreign 2>/dev/null` 
reset=`uci get mwan3.base.reset 2>/dev/null` 
mmx_mask=`uci get mwan3.globals.mmx_mask 2>/dev/null` 
[ -z $mmx_mask ] && mmx_mask="0xff00"

IPT4="/usr/sbin/iptables -t mangle -w"
number=0

chk_ip_list="www.qq.com www.baidu.com www.taobao.com 114.114.114.114 119.29.29.29 1.2.4.8"

mwan_cfg_add() {
	#gen mwan3_interface
	uci set mwan3.${1}=interface 2>/dev/null
	uci set mwan3.${1}.enabled=1 2>/dev/null
	uci set mwan3.${1}.count=1 2>/dev/null
	uci set mwan3.${1}.timeout=2 2>/dev/null
	uci set mwan3.${1}.interval=5 2>/dev/null
	uci set mwan3.${1}.down=4 2>/dev/null
	uci set mwan3.${1}.up=1 2>/dev/null
	uci set mwan3.${1}.initial_state=online 2>/dev/null
	uci set mwan3.${1}.track_method=ping 2>/dev/null
	uci set mwan3.${1}.family="ipv4" 2>/dev/null
	uci set mwan3.${1}.size=56 2>/dev/null
	uci set mwan3.${1}.failure_interval=5 2>/dev/null
	uci set mwan3.${1}.recovery_interval=5 2>/dev/null
	uci set mwan3.${1}.flush_conntrack="never" 2>/dev/null
	for i in $chk_ip_list
	do
		uci add_list mwan3.${1}.track_ip="$i" 2>/dev/null
	done
	uci set mwan3.${1}.reliability=1 2>/dev/null
	#gen mwan3_member
	uci set mwan3.${1}_m1=member 2>/dev/null
	uci set mwan3.${1}_m1.interface=${1} 2>/dev/null
	uci set mwan3.${1}_m1.metric=1 2>/dev/null
	uci set mwan3.${1}_m1.weight=1 2>/dev/null
	#gen mwan3_policy
	uci set mwan3.${1}_m1p=policy 2>/dev/null
	uci add_list mwan3.${1}_m1p.use_member=${1}_m1 2>/dev/null
	uci set mwan3.${1}_m1p.last_resort=unreachable 2>/dev/null
	uci add_list mwan3.balanced.use_member=${1}_m1 2>/dev/null
}

mwan_cfg_del() {
	uci del mwan3.${1} 2>/dev/null
	uci del mwan3.${1}_m1 2>/dev/null
	uci del mwan3.${1}_m1p 2>/dev/null
	uci del_list mwan3.balanced.use_member=${1} 2>/dev/null
	uci del_list mwan3.balanced.use_member=${1}_m1 2>/dev/null
}

mwan_reset_cfg() {
if [ "$reset" == "1" ]; then
cat > /etc/config/mwan3 <<EOF
config rule 'default_rule'
	option enable '1'
	option dest_ip '0.0.0.0/0'
	option use_policy 'balanced'

config policy 'balanced'
	option last_resort 'unreachable'
	list use_member 'wan_m1'

config mpolicy 'base'
	option enable '0'
	option reset '0'
	option telecom 'none'
	option unicom 'none'
	option mobile 'none'
	option cernet 'none'
	option cnn 'none'
	option foreign 'none'

config interface 'wan'
	option enabled '1'
	option count '1'
	option timeout '2'
	option interval '5'
	option down '3'
	option up '2'
	list track_ip '223.5.5.5'
	list track_ip '119.29.29.29'
	list track_ip '114.114.114.114'
	list track_ip 'www.taobao.com'
	list track_ip 'www.qq.com'
	option initial_state 'online'
	option track_method 'ping'
	option reliability '1'
	option family 'ipv4'
	option size '56'
	option failure_interval '5'
	option recovery_interval '5'
	option flush_conntrack 'never'

config member 'wan_m1'
	option interface 'wan'
	option metric '1'
	option weight '1'

config policy 'wan_m1p'
	list use_member 'wan_m1'
	option last_resort 'unreachable'

EOF
uci set mwan3.base.reset="0"
uci commit
fi
}

mwan3_policy_iface_start() 
{
mwan_reset_cfg
if [ "$policyenable" = "1" ]; then
	if [ $mobile != "none" ]; then
		mwan_cfg_del $mobile
		use_mobile="/usr/share/policy/mobile.txt"
		sed -e "s/^/-A mwan3_mobile &/g" -e "1 i\-N mwan3_mobile nethash" $use_mobile | awk '{print $0} END{print "COMMIT"}' | ipset -R
		mwan_cfg_add $mobile
	fi
	if [ $cernet != "none" ]; then
		mwan_cfg_del $cernet
		use_cernet="/usr/share/policy/cernet.txt"
		sed -e "s/^/-A mwan3_cernet &/g" -e "1 i\-N mwan3_cernet nethash" $use_cernet | awk '{print $0} END{print "COMMIT"}' | ipset -R
		mwan_cfg_add $cernet
	fi
	if [ $unicom != "none" ]; then
		mwan_cfg_del $unicom
		use_unicom="/usr/share/policy/unicom.txt"
		sed -e "s/^/-A mwan3_unicom &/g" -e "1 i\-N mwan3_unicom nethash" $use_unicom | awk '{print $0} END{print "COMMIT"}' | ipset -R
		mwan_cfg_add $unicom
	fi
	if [ $telecom != "none" ]; then
		mwan_cfg_del $telecom 
		use_telecom="/usr/share/policy/telecom.txt"
		sed -e "s/^/-A mwan3_telecom &/g" -e "1 i\-N mwan3_telecom nethash" $use_telecom | awk '{print $0} END{print "COMMIT"}' | ipset -R
		mwan_cfg_add $telecom
	fi
	if [ $cnn != "none" ]; then
		mwan_cfg_del $cnn
		mwan_cfg_add $cnn
	fi
	if [ $foreign != "none" ]; then
		mwan_cfg_del $foreign
		mwan_cfg_add $foreign
	fi
uci commit
fi
}

mwan3_policy_iptables_start() 
{
if [ "$policyenable" = "1" ]; then	
	if [ $mobile != "none" ]; then
		number=`expr $number + 1`
		$IPT4 -I mwan3_rules $number -m set --match-set mwan3_mobile dst -m mark --mark 0x0/$mmx_mask -m comment --comment "mobile by fw867" -j "mwan3_policy_"$mobile"_m1p"
	fi
	if [ $cernet != "none" ]; then
    number=`expr $number + 1`
		$IPT4 -I mwan3_rules $number -m set --match-set mwan3_cernet dst -m mark --mark 0x0/$mmx_mask -m comment --comment "cernet by fw867" -j "mwan3_policy_"$cernet"_m1p"
	fi
	if [ $unicom != "none" ]; then
		number=`expr $number + 1`
		$IPT4 -I mwan3_rules $number -m set --match-set mwan3_unicom dst -m mark --mark 0x0/$mmx_mask -m comment --comment "unicom by fw867" -j "mwan3_policy_"$unicom"_m1p"
	fi
	if [ $telecom != "none" ]; then
		number=`expr $number + 1`
		$IPT4 -I mwan3_rules $number -m set --match-set mwan3_telecom dst -m mark --mark 0x0/$mmx_mask -m comment --comment "telecom by fw867" -j "mwan3_policy_"$telecom"_m1p"
	fi
	if [ $cnn != "none" ]; then
		number=`expr $number + 1`
		$IPT4 -I mwan3_rules $number -m geoip --destination-country CN -m mark --mark 0x0/$mmx_mask -m comment --comment "china by fw867" -j "mwan3_policy_"$cnn"_m1p"
	fi
	if [ $foreign != "none" ]; then
		number=`expr $number + 1`
		$IPT4 -I mwan3_rules $number -m geoip ! --destination-country CN -m mark --mark 0x0/$mmx_mask -m comment --comment "foreign by fw867" -j "mwan3_policy_"$foreign"_m1p"
	fi
fi
}

mwan3_policy_ipset_stop()
{
	ipset -F mwan3_mobile 2>/dev/null
	ipset -F mwan3_telecom 2>/dev/null
	ipset -F mwan3_cernet 2>/dev/null
	ipset -F mwan3_unicom 2>/dev/null
	ipset -X mwan3_mobile 2>/dev/null
	ipset -X mwan3_telecom 2>/dev/null
	ipset -X mwan3_cernet 2>/dev/null
	ipset -X mwan3_unicom 2>/dev/null
}
