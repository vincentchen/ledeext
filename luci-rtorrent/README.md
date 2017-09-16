# luci-app-rtorrent
rTorrent client for OpenWrt's LuCI web interface
Based on https://github.com/wolandmaster/luci-app-rtorrent , with some modifications:
- wolandmaster's package will cause luci error when rtorrent is not running with hardcoded scgi port, this one doesn't.
- More detailed configuration, togglable webui
- Dependencies like lua-xmlrpc are splitted into seperated packages (look into lang/lua directory)
- Chinese translations (not complete)
