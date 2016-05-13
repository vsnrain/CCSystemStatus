TARGET = iphone:clang:9.2:7.0
ARCHS = armv7 armv7s arm64
SHARED_CFLAGS = -fobjc-arc
SYSROOT = $(THEOS)/sdks/iPhoneOS9.2.sdk

THEOS_STAGING_DIR = ../Staging
THEOS_PACKAGE_DIR = ../Packages
THEOS_OBJ_DIR_NAME = $(_THEOS_LOCAL_DATA_DIR)/Obj

_THEOS_PLATFORM_DPKG_DEB_COMPRESSION = bzip2

include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = CCSystemStatusSettings
CCSystemStatusSettings_CFLAGS = -fobjc-arc
CCSystemStatusSettings_INSTALL_PATH = /Library/PreferenceBundles
CCSystemStatusSettings_FRAMEWORKS = Foundation UIKit
CCSystemStatusSettings_PRIVATE_FRAMEWORKS = Preferences
CCSystemStatusSettings_FILES = CCSystemStatusSettings.mm

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/CCSystemStatusSettings.plist$(ECHO_END)

after-install::
	install.exec "killall -9 backboardd"
