THEOS_DEVICE_IP = 192.168.3.224
export ARCHS = armv7 armv7s arm64


include theos/makefiles/common.mk

TWEAK_NAME = recordscript
recordscript_FILES = Tweak.xm
recordscript_FRAMEWORKS = UIKit CoreGraphics
recordscript_PRIVATE_FRAMEWORKS = IOSurface IOKit IOMobileFramebuffer
recordscript_CFLAGS = -I./headers/ -I./headers/IOSurface


include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"
