include $(TOPDIR)/rules.mk

LUCI_TITLE:=LuCI support for softethervpn
LUCI_PKGARCH:=all

include $(TOPDIR)/feeds/luci/luci.mk

define Package/$(PKG_NAME)/postinst
#!/bin/sh
chmod 755 $${IPKG_INSTROOT}/etc/init.d/softethervpn >/dev/null 2>&1
chmod 755 $${IPKG_INSTROOT}/usr/libexec/softethervpn/firewall.include >/dev/null 2>&1
exit 0
endef

# call BuildPackage - OpenWrt buildroot signature
