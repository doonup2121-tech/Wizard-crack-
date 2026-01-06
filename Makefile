ARCHS = arm64 arm64e
TARGET = iphone:clang:latest:14.0

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = DooN_Wizard
DooN_Wizard_FILES = Tweak.x
DooN_Wizard_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk