local e=require"luci.sys"
local a,e,t
a=Map("softethervpn",translate("SoftEther VPN"),translate("SoftEther VPN是由筑波大学研究生Daiyuu Nobori因硕士论文开发的开源，跨平台，多重协定的虚拟私人网路方案。<br/>使用控制台可以轻松在路由器上搭建OpenVPN, IPsec, L2TP, MS-SSTP, L2TPv3 和 EtherIP服务器"))
a.template="softethervpn/index"
e=a:section(TypedSection,"softether",translate("Running Status"))
e.anonymous=true
t=e:option(DummyValue,"softethervpn_status",translate("当前状态"))
t.template="softethervpn/softethervpn"
t.value=translate("Collecting data...")
e=a:section(TypedSection,"softether",translate("基本设置"))
e.anonymous=true
t=e:option(Flag,"enable",translate("开启"))
t.rmempty=false
e=a:section(TypedSection,"softether",translate("防火墙设置"))
e.anonymous=true
t=e:option(Flag,"l2tp",translate("开启L2TP/IPSEC防火墙"))
t.rmempty=false
t=e:option(Flag,"sstp",translate("开启MS-SSTP防火墙"))
t.rmempty=false
t=e:option(Flag,"openvpn",translate("开启OPENVPN防火墙"))
t.rmempty=false
e=a:section(TypedSection,"softether",translate("设置教程"))
e.anonymous=true
t=e:option(DummyValue,"moreinfo",translate("</label><div style=\"float:left;\">LUCI：fw867<br/>版本：Ver 4.22, Build 9634, beta<br/><br/><strong>控制台下载：<a onclick=\"window.open('http://www.softether-download.com/files/softether/v4.22-9634-beta-2016.11.27-tree/Windows/SoftEther_VPN_Server_and_VPN_Bridge/softether-vpnserver_vpnbridge-v4.22-9634-beta-2016.11.27-windows-x86_x64-intel.exe')\"><br/>Windows-x86_x64-intel.exe</a><a  onclick=\"window.open('http://www.softether-download.com/files/softether/v4.21-9613-beta-2016.04.24-tree/Mac_OS_X/Admin_Tools/VPN_Server_Manager_Package/softether-vpnserver_manager-v4.21-9613-beta-2016.04.24-macos-x86-32bit.pkg')\"><br/>macos-x86-32bit.pkg</a></strong><br/><br/><strong>设置教程：<a  onclick=\"window.open('http://koolshare.cn/thread-67572-1-1.html')\">Koolshare论坛</a></strong><br/>更多详情请访问：<a  onclick=\"window.open('http://www.softether.org/1-features')\">http://www.softether.org</a><br/><br/></div></div><label>"))
return a
