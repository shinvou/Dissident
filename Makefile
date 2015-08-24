THEOS_DEVICE_IP = 127.0.0.1
THEOS_DEVICE_PORT = 2222
THEOS_PACKAGE_DIR_NAME = deb

GO_EASY_ON_ME = 1

ARCHS = armv7 arm64
TARGET = iphone:clang:latest:8.0

include theos/makefiles/common.mk

TWEAK_NAME = Dissident
Dissident_FILES = $(wildcard *.xm) $(wildcard DissidentActivator/*.xm) $(wildcard DissidentActivator/ActivatorActions/*.m)
Dissident_CFLAGS = -fobjc-arc
Dissident_LIBRARIES = substrate
Dissident_FRAMEWORKS = UIKit Social CoreGraphics AppleAccount
Dissident_PRIVATE_FRAMEWORKS = AssertionServices FrontBoard

include $(THEOS_MAKE_PATH)/tweak.mk

SUBPROJECTS += DissidentSettings

include $(THEOS_MAKE_PATH)/aggregate.mk

before-stage::
	find . -name ".DS_Store" -delete
after-install::
	install.exec "killall -9 backboardd"
