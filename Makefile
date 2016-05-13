THEOS_STAGING_DIR = Staging
THEOS_PACKAGE_DIR = Packages
THEOS_OBJ_DIR_NAME = $(_THEOS_LOCAL_DATA_DIR)/Obj

_THEOS_PLATFORM_DPKG_DEB_COMPRESSION = bzip2

DEBUG = 1
PACKAGE_VERSION = 1.3

include $(THEOS)/makefiles/common.mk

SUBPROJECTS += ccsystemstatus-core
SUBPROJECTS += ccsystemstatus-settings
include $(THEOS_MAKE_PATH)/aggregate.mk

after-install::
	install.exec "killall -9 SpringBoard"
