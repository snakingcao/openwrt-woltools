include $(TOPDIR)/rules.mk

PKG_NAME:=luci-app-woltools
PKG_VERSION:=1.0.0
PKG_RELEASE:=$(shell date +%Y%m%d_%H%M%S)

PKG_MAINTAINER:=iStoreOS
PKG_LICENSE:=GPL-3.0

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)

include $(INCLUDE_DIR)/package.mk

define Package/$(PKG_NAME)
	SECTION:=luci
	CATEGORY:=LuCI
	SUBMENU:=3. Applications
	TITLE:=LuCI Support for Wake-on-LAN Tools
	PKG_ARCH:=all
	DEPENDS:=+luci-base +etherwake
endef

define Package/$(PKG_NAME)/description
	LuCI Support for Wake-on-LAN Tools.
	Provides a web interface to manage and wake up devices using Wake-on-LAN.
endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
	cp -R ./demo.html $(PKG_BUILD_DIR)/
endef

define Build/Compile
	@echo "Updating version information..."
	@sed -i "s/<meta name=\"version\" content=\".*\">/<meta name=\"version\" content=\"$(PKG_VERSION)-$(PKG_RELEASE)\">/" $(PKG_BUILD_DIR)/demo.html
	@sed -i "s/<meta name=\"version\" content=\".*\">/<meta name=\"version\" content=\"$(PKG_VERSION)-$(PKG_RELEASE)\">/" ./luasrc/view/woltools.htm
endef

define Package/$(PKG_NAME)/install
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/controller
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/model/cbi
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/view
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_DIR) $(1)/usr/share/rpcd/acl.d
	$(INSTALL_DIR) $(1)/www/woltools

	$(INSTALL_DATA) ./luasrc/controller/* $(1)/usr/lib/lua/luci/controller/
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/demo.html $(1)/www/woltools/
	$(INSTALL_DATA) ./luasrc/model/cbi/* $(1)/usr/lib/lua/luci/model/cbi/
	$(INSTALL_DATA) ./luasrc/view/* $(1)/usr/lib/lua/luci/view/
	$(INSTALL_CONF) ./root/etc/config/woltools $(1)/etc/config/
	$(INSTALL_BIN) ./root/usr/bin/woltools $(1)/usr/bin/
	$(INSTALL_DATA) ./root/usr/share/rpcd/acl.d/* $(1)/usr/share/rpcd/acl.d/
endef

$(eval $(call BuildPackage,$(PKG_NAME)))
DEPENDS:=+luci-base +etherwake