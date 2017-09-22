include $(TOPDIR)/rules.mk

LUCI_TITLE:=LuCI support for ssr server
LUCI_PKGARCH:=all

include $(TOPDIR)/feeds/luci/luci.mk

define Package/$(PKG_NAME)/postinst
#!/bin/sh
chmod 755 $${IPKG_INSTROOT}/etc/init.d/ssr_server >/dev/null 2>&1
exit 0
endef

# call BuildPackage - OpenWrt buildroot signature
