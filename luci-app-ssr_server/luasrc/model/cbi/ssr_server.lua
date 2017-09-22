local a,t,e
local o=require"nixio.fs"
local n={
"none",
"rc4-md5",
"aes-128-cfb",
"aes-192-cfb",
"aes-256-cfb",
"aes-128-ctr",
"aes-192-ctr",
"aes-256-ctr",
"salsa20",
"chacha20",
"chacha20-ietf",
}
local s={
"origin",
"verify_deflate",
"auth_sha1_v4",
"auth_aes128_md5",
"auth_aes128_sha1",
"auth_chain_a",
}
local i={
"plain",
"http_simple",
"http_post",
"random_head",
"tls1.2_ticket_auth",
}
local o={
"false",
"true",
}
a=Map("ssr_server",translate("ShadowSocks Server Config"),translate("Set up a Shadowsocks server on your router"))
a.template="ssr_server/index"
t=a:section(TypedSection,"global",translate("Running Status"))
t.anonymous=true
e=t:option(DummyValue,"server_status",translate("Current Status"))
e.template="ssr_server/dvalue"
e.value=translate("Collecting data...")
t=a:section(TypedSection,"global",translate("Global Setting"))
t.anonymous=true
t.addremove=false
e=t:option(Flag,"enable",translate("Enable"))
e.rmempty=false
t=a:section(TypedSection,"server",translate("ShadowSocks Server Config"))
t.anonymous=true
t.addremove=false
e=t:option(Value,"server_port",translate("Server Port"))
e.datatype="port"
e.rmempty=false
e.default=139
e=t:option(ListValue,"encrypt_method",translate("Encrypt Method"))
for a,t in ipairs(n)do e:value(t)end
e.rmempty=false
e=t:option(ListValue,"protocol",translate("Protocol"))
for a,t in ipairs(s)do e:value(t)end
e.rmempty=false
e=t:option(Value,"protocol_param",translate("Protocol_param"))
e.rmempty=true
e=t:option(ListValue,"obfs",translate("Obfs"))
for a,t in ipairs(i)do e:value(t)end
e.rmempty=false
e=t:option(Value,"obfs_param",translate("Obfs_param"))
e.rmempty=true
e=t:option(Value,"password",translate("Password"))
e.password=true
e.rmempty=false
e=t:option(Value,"redirect",translate("redirect"))
e.rmempty=true
e=t:option(Value,"timeout",translate("Connection Timeout"))
e.datatype="uinteger"
e.default=300
e.rmempty=false
e=t:option(ListValue,"fast_open",translate("Fast_open"))
for a,t in ipairs(o)do e:value(t)end
e.rmempty=false
e=t:option(ListValue,"connect_verbose_info",translate("Verbose LogInfo"))
e.default=0
e:value(1,translate("ON"))
e:value(0,translate("OFF"))
e.rmempty=false
t=a:section(TypedSection,"server",translate("ShadowSocks Server logs"))
t.anonymous=true
t.addremove=false
local e="/var/log/ssr_server.log"
tvlog=t:option(TextValue,"sylogtext")
tvlog.rows=20
tvlog.readonly="readonly"
tvlog.wrap="off"
function tvlog.cfgvalue(t,t)
sylogtext=""
if e and nixio.fs.access(e)then
sylogtext=luci.sys.exec("tail -n 19 %s"%e)
end
return sylogtext
end
tvlog.write=function(e,e,e)
end
return a
