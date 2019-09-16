SPK_NAME = autosub
SPK_VERS = $(shell date +%Y%m%d)
SPK_REV = 1
SPK_ICON = src/autosub.png
DSM_UI_DIR = app

DEPENDS  =
SPK_DEPENDS = "python>2.7.3-3:git"

MAINTAINER = BenjV
DISTRIBUTOR = Martijn de Vries
DESCRIPTION = Automated SubtitleSeeker and Addic7ed download script for TV-Series.
DESCRIPTION_NLD = Geautomatiseerde SubtitleSeeker en Addic7ed download script voor TV-Series.
ADMIN_PORT = 9960
RELOAD_UI = yes
DISPLAY_NAME = AutoSub
CHANGELOG = "1. Rebuild the package."

HOMEPAGE   = https://github.com/BenjV/autosub
LICENSE    =

INSTALLER_SCRIPT = src/installer.sh
SSS_SCRIPT       = src/dsm-control.sh
FWPORTS          = src/${SPK_NAME}.sc
CONF_DIR         = src/conf/
WIZARDS_DIR      =

INSTALL_PREFIX = /usr/local/$(SPK_NAME)

COPY_TARGET = nop
POST_STRIP_TARGET = autosub_extra_install

# Pure Python package, make sure ARCH is not defined
override ARCH=

include ../../mk/spksrc.spk.mk

.PHONY: autosub_extra_install
autosub_extra_install: $(STAGING_DIR)/share/autosub
	install -m 755 -d $(STAGING_DIR)/app
	install -m 644 src/app/config $(STAGING_DIR)/app/config
	install -m 755 -d $(STAGING_DIR)/app/images
	for size in 16 24 32 48 72; do \
		convert $(SPK_ICON) -thumbnail $${size}x$${size} \
		        $(STAGING_DIR)/app/images/$(SPK_NAME)-$${size}.png ; \
	done
	mv $(STAGING_DIR)/share/autosub/* $(STAGING_DIR)
	rm -R $(STAGING_DIR)/share

$(STAGING_DIR)/share/autosub:
	install -m 755 -d $(STAGING_DIR)/share
	cd $(STAGING_DIR)/share && git clone https://github.com/BenjV/autosub.git
	rm -fr $(STAGING_DIR)/share/autosub/.git $(STAGING_DIR)/share/autosub/.gitignore