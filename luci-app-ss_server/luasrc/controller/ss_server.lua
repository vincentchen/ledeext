module("luci.controller.ss_server",package.seeall)
function index()
if not nixio.fs.access("/etc/config/ss_server")then
return
end
entry({"admin","vpn","ss_server"},cbi("ss_server"),_("shadowsocks-server"),4).dependent=true
entry({"admin","vpn","ss_server","status"},call("act_status")).leaf=true
end
function act_status()
local e={}
e.server=luci.sys.call("ps | grep ss-server |grep -v grep >/dev/null")==0
luci.http.prepare_content("application/json")
luci.http.write_json(e)
end
