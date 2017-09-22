module("luci.controller.protocolfiltering",package.seeall)
function index()
if not nixio.fs.access("/etc/config/protocolfiltering")then
return
end
entry({"admin","control","protocolfiltering"},cbi("protocolfiltering"),_("协议过滤"),13).dependent=true
entry({"admin","control","protocolfiltering","status"},call("status")).leaf=true
end
function status()
local e={}
e.protocolfiltering=luci.sys.call("iptables -L FORWARD|grep PROTOCOL_FILTER >/dev/null")==0
luci.http.prepare_content("application/json")
luci.http.write_json(e)
end
