local i=require"luci.sys"
local a=require"luci.tools.webadmin"
local o,t,e
o=Map("protocolfiltering",translate("协议过滤"),translate("在这里设置DPI协议过滤，如http、https、QQ"))
o.template="protocolfiltering/index"
t=o:section(TypedSection,"basic",translate("Running Status"))
t.anonymous=true
e=t:option(DummyValue,"protocolfiltering_status",translate("当前状态"))
e.template="protocolfiltering/protocolfiltering"
e.value=translate("Collecting data...")
t=o:section(TypedSection,"basic",translate("基本设置"))
t.anonymous=true
e=t:option(Flag,"enable",translate("开启"))
e.rmempty=false
t=o:section(TypedSection,"macbind",translate("关键词设置"),translate("内部IP不设置为全客户端过滤，如设置只过滤指定的客户端。过滤时间可不设置。"))
t.template="cbi/tblsection"
t.anonymous=true
t.addremove=true
e=t:option(Flag,"enable",translate("开启控制"))
e.rmempty=false
e=t:option(Value,"macaddr",translate("内部IP地址"))
e.rmempty=true
a.cbi_add_knownips(e)
e.datatype="and(ipaddr)"
e=t:option(Value,"timeon",translate("开始过滤时间"))
e.placeholder="00:00"
e.rmempty=true
e=t:option(Value,"timeoff",translate("取消过滤时间"))
e.placeholder="23:59"
e.rmempty=true
if(tonumber(i.exec("lsmod | cut -d ' ' -f 1 | grep -c 'xt_ndpi'")))>0 then
ndpi=t:option(Value,"ndpi",translate("DPI protocol"))
local o=io.popen("iptables -m ndpi --help | grep -e '^--'")
if o then
local t,e,a,s,n,i
while true do
t=o:read("*l")
if not t then break end
e,a=t:find("%-%-[^%s]+")
if e and a then
n=t:sub(e+2,a)
end
e,a=t:find("for [^%s]+ protocol")
if e and a then
i=t:sub(e+3,a-9)
end
ndpi:value(n,i)
end
o:close()
end
end
return o
