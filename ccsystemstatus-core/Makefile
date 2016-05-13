TARGET = iphone:clang:9.2:7.0
ARCHS = armv7 armv7s arm64
SHARED_CFLAGS = -fobjc-arc
SYSROOT = $(THEOS)/sdks/iPhoneOS9.2.sdk

THEOS_STAGING_DIR = ../Staging
THEOS_PACKAGE_DIR = ../Packages
THEOS_OBJ_DIR_NAME = $(_THEOS_LOCAL_DATA_DIR)/Obj

_THEOS_PLATFORM_DPKG_DEB_COMPRESSION = bzip2

include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = CCSystemStatus
CCSystemStatus_CFLAGS = -fobjc-arc
CCSystemStatus_INSTALL_PATH = /Library/CCLoader/Bundles
CCSystemStatus_FRAMEWORKS = Foundation UIKit SystemConfiguration
CCSystemStatus_FILES = CCSystemStatusSection.m CCSystemStatusSectionView.m

include $(THEOS_MAKE_PATH)/bundle.mk

after-install::
	install.exec "killall -9 backboardd"
