module("luci.controller.mwan3",package.seeall)
sys=require"luci.sys"
ut=require"luci.util"
ip="ip -4 "
function index()
if not nixio.fs.access("/etc/config/mwan3")then
return
end
entry({"admin","network","mwan"},
alias("admin","network","mwan","overview"),
_("Load Balancing"),600)
entry({"admin","network","mwan","overview"},
alias("admin","network","mwan","overview","overview_interface"),
_("Overview"),10)
entry({"admin","network","mwan","overview","overview_interface"},
template("mwan/overview_interface"))
entry({"admin","network","mwan","overview","interface_status"},
call("interfaceStatus"))
entry({"admin","network","mwan","overview","overview_detailed"},
template("mwan/overview_detailed"))
entry({"admin","network","mwan","overview","detailed_status"},
call("detailedStatus"))
entry({"admin","network","mwan","mpolicy"},
alias("admin","network","mwan","mpolicy","mpolicy"),
_("Multi-isp PBR"),15)
entry({"admin","network","mwan","mpolicy","mpolicy"},
arcombine(cbi("mwan/mpolicy"),cbi("mwan/policyconfig")),
_("Multi-isp policy-Based routing"),10).leaf=true
entry({"admin","network","mwan","configuration"},
alias("admin","network","mwan","configuration","interface"),
_("Configuration"),20)
entry({"admin", "network", "mwan", "configuration", "globals"},
	cbi("mwan/globalsconfig"),_("Globals"), 5).leaf = true
entry({"admin","network","mwan","configuration","interface"},
arcombine(cbi("mwan/interface"),cbi("mwan/interfaceconfig")),
_("Interfaces"),10).leaf=true
entry({"admin","network","mwan","configuration","member"},
arcombine(cbi("mwan/member"),cbi("mwan/memberconfig")),
_("Members"),20).leaf=true
entry({"admin","network","mwan","configuration","policy"},
arcombine(cbi("mwan/policy"),cbi("mwan/policyconfig")),
_("Policies"),30).leaf=true
entry({"admin","network","mwan","configuration","rule"},
arcombine(cbi("mwan/rule"),cbi("mwan/ruleconfig")),
_("Rules"),40).leaf=true
entry({"admin","network","mwan","advanced"},
alias("admin","network","mwan","advanced","hotplugscript"),
_("Advanced"),100)
entry({"admin","network","mwan","advanced","hotplugscript"},
form("mwan/advanced_hotplugscript"))
entry({"admin","network","mwan","advanced","mwanconfig"},
form("mwan/advanced_mwanconfig"))
entry({"admin","network","mwan","advanced","networkconfig"},
form("mwan/advanced_networkconfig"))
entry({"admin","network","mwan","advanced","wirelessconfig"},
form("mwan/advanced_wirelessconfig"))
entry({"admin","network","mwan","advanced","diagnostics"},
template("mwan/advanced_diagnostics"))
entry({"admin","network","mwan","advanced","diagnostics_display"},
call("diagnosticsData"),nil).leaf=true
entry({"admin","network","mwan","advanced","troubleshooting"},
template("mwan/advanced_troubleshooting"))
entry({"admin","network","mwan","advanced","troubleshooting_display"},
call("troubleshootingData"))
entry({"admin","network","mwan","status"},call("status")).leaf=true
end
function status()
local e={
running=(sys.call("iptables -t mangle -nvL mwan3_rules|grep fw867 > /dev/null")==0),
}
luci.http.prepare_content("application/json")
luci.http.write_json(e)
end
function getInterfaceStatus(t,e)
if ut.trim(sys.exec("uci -q -p /var/state get mwan3."..e..".enabled"))=="1"then
if ut.trim(sys.exec(ip.."route list table "..t))~=""then
if ut.trim(sys.exec("uci -q -p /var/state get mwan3."..e..".track_ip"))~=""then
return"online"
else
return"notMonitored"
end
else
return"offline"
end
else
return"notEnabled"
end
end
function getInterfaceName()
local e,t=0,""
uci.cursor():foreach("mwan3","interface",
function(a)
e=e+1
t=t..a[".name"].."["..getInterfaceStatus(e,a[".name"]).."]"
end
)
return t
end
function interfaceStatus()
local n=require"luci.model.network".init()
local t={}
local e=getInterfaceName()
if e~=""then
t.wans={}
wansid={}
for o,i in string.gfind(e,"([^%[]+)%[([^%]]+)%]")do
local a=ut.trim(sys.exec("uci -q -p /var/state get network."..o..".ifname"))
if a==""then
a="X"
end
local e=n:get_interface(a)
e=e and e:get_network()
e=e and e:adminlink()or"#"
wansid[o]=#t.wans+1
t.wans[wansid[o]]={name=o,link=e,ifname=a,status=i}
end
end
local e=ut.trim(sys.exec("logread | grep mwan3 | tail -n 50 | sed 'x;1!H;$!d;x' 2>/dev/null"))
if e~=""then
t.mwanlog={e}
end
luci.http.prepare_content("application/json")
luci.http.write_json(t)
end
function detailedStatus()
local e={}
local t=ut.trim(sys.exec("/usr/sbin/mwan3 status"))
if t~=""then
e.mwandetail={t}
end
luci.http.prepare_content("application/json")
luci.http.write_json(e)
end
function diagnosticsData(t,o,a)
function getInterfaceNumber()
local e=0
uci.cursor():foreach("mwan3","interface",
function(a)
e=e+1
if a[".name"]==t then
interfaceNumber=e
end
end
)
end
local n={}
local e=""
if o=="service"then
os.execute("/usr/sbin/mwan3 "..a)
if a=="restart"then
e="MWAN3 restarted"
elseif a=="stop"then
e="MWAN3 stopped"
else
e="MWAN3 started"
end
else
local i=ut.trim(sys.exec("uci -q -p /var/state get network."..t..".ifname"))
if i~=""then
if o=="ping"then
local o=ut.trim(sys.exec("route -n | awk '{if ($8 == \""..i.."\" && $1 == \"0.0.0.0\" && $3 == \"0.0.0.0\") print $2}'"))
if o~=""then
if a=="gateway"then
local t="ping -c 3 -W 2 -I "..i.." "..o
e=t.."\n\n"..sys.exec(t)
else
local a=ut.trim(sys.exec("uci -q -p /var/state get mwan3."..t..".track_ip"))
if a~=""then
for t in a:gmatch("[^ ]+")do
local t="ping -c 3 -W 2 -I "..i.." "..t
e=e..t.."\n\n"..sys.exec(t).."\n\n"
end
else
e="No tracking IP addresses configured on "..t
end
end
else
e="No default gateway for "..t.." found. Default route does not exist or is configured incorrectly"
end
elseif o=="rulechk"then
getInterfaceNumber()
local a=sys.exec(ip.."rule | grep $(echo $(("..interfaceNumber.." + 1000)))")
local t=sys.exec(ip.."rule | grep $(echo $(("..interfaceNumber.." + 2000)))")
if a~=""and t~=""then
e="All required interface IP rules found:\n\n"..a..t
elseif a~=""or t~=""then
e="Missing 1 of the 2 required interface IP rules\n\n\nRules found:\n\n"..a..t
else
e="Missing both of the required interface IP rules"
end
elseif o=="routechk"then
getInterfaceNumber()
local t=sys.exec(ip.."route list table "..interfaceNumber)
if t~=""then
e="Interface routing table "..interfaceNumber.." was found:\n\n"..t
else
e="Missing required interface routing table "..interfaceNumber
end
elseif o=="hotplug"then
if a=="ifup"then
os.execute("/usr/sbin/mwan3 ifup "..t)
e="Hotplug ifup sent to interface "..t.."..."
else
os.execute("/usr/sbin/mwan3 ifdown "..t)
e="Hotplug ifdown sent to interface "..t.."..."
end
end
else
e="Unable to perform diagnostic tests on "..t..". There is no physical or virtual device associated with this interface"
end
end
if e~=""then
e=ut.trim(e)
n.diagnostics={e}
end
luci.http.prepare_content("application/json")
luci.http.write_json(n)
end
function troubleshootingData()
local t=require"luci.version"
local e={}
local a=ut.trim(t.distversion)
if a~=""then
a="OpenWrt - "..a
else
a="OpenWrt - unknown"
end
local i=ut.trim(t.luciversion)
if i~=""then
i="\nLuCI - "..i
else
i="\nLuCI - unknown"
end
local t=ut.trim(sys.exec("opkg info mwan5 | grep Version | awk '{print $2}'"))
if t~=""then
t="\n\nmwan3 - "..t
else
t="\n\nmwan3 - unknown"
end
local o=ut.trim(sys.exec("opkg info luci-app-mwan5 | grep Version | awk '{print $2}'"))
if o~=""then
o="\nmwan3-luci - "..o
else
o="\nmwan3-luci - unknown"
end
e.versions={a..i..t..o}
local t=ut.trim(sys.exec("cat /etc/config/mwan3"))
if t==""then
t="No data found"
end
e.mwanconfig={t}
local t=ut.trim(sys.exec("cat /etc/config/network | sed -e 's/.*username.*/	USERNAME HIDDEN/' -e 's/.*password.*/	PASSWORD HIDDEN/'"))
if t==""then
t="No data found"
end
e.netconfig={t}
local t=ut.trim(sys.exec("cat /etc/config/wireless | sed -e 's/.*username.*/	USERNAME HIDDEN/' -e 's/.*password.*/	PASSWORD HIDDEN/' -e 's/.*key.*/	KEY HIDDEN/'"))
if t==""then
t="No data found"
end
e.wificonfig={t}
local t=ut.trim(sys.exec("ifconfig"))
if t==""then
t="No data found"
end
e.ifconfig={t}
local t=ut.trim(sys.exec("route -n"))
if t==""then
t="No data found"
end
e.routeshow={t}
local t=ut.trim(sys.exec(ip.."rule show"))
if t==""then
t="No data found"
end
e.iprule={t}
local a,t=ut.trim(sys.exec(ip.."rule | sed 's/://g' 2>/dev/null | awk '$1>=2001 && $1<=2250' | awk '{print $NF}'")),""
if a~=""then
for e in a:gmatch("[^\r\n]+")do
t=t..e.."\n"..sys.exec(ip.."route list table "..e)
end
t=ut.trim(t)
else
t="No data found"
end
e.routelist={t}
local t=ut.trim(sys.exec("uci -q -p /var/state get firewall.@defaults[0].output"))
if t==""then
t="No data found"
end
e.firewallout={t}
local t=ut.trim(sys.exec("iptables -L -t mangle -v -n"))
if t==""then
t="No data found"
end
e.iptables={t}
luci.http.prepare_content("application/json")
luci.http.write_json(e)
end
