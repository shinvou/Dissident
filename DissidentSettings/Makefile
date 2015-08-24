GO_EASY_ON_ME = 1

ARCHS = armv7 arm64
TARGET = iphone:clang:latest:8.0

include theos/makefiles/common.mk

TWEAK_NAME = Dissident_Settings
Dissident_Settings_FILES = Settings.xm $(wildcard SettingsStuff/*.m)
Dissident_Settings_CFLAGS = -fobjc-arc
Dissident_Settings_LIBRARIES = substrate applist
Dissident_Settings_FRAMEWORKS = Social UIKit GoogleMobileAds AdSupport AudioToolbox AVFoundation CoreGraphics CoreMedia CoreTelephony EventKit EventKitUI MessageUI StoreKit SystemConfiguration QuartzCore

include $(THEOS_MAKE_PATH)/tweak.mk
