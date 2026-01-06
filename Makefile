ARCHS = arm64 arm64e
TARGET = iphone:clang:14.5:14.0
DEBUG = 0
FINAL_PACKAGE = 1

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = DooN_Wizard

DooN_Wizard_FILES = Tweak.x
DooN_Wizard_CFLAGS = -fobjc-arc -Wno-deprecated-declarations -Wno-unused-variable
DooN_Wizard_FRAMEWORKS = UIKit Foundation Security

include $(THEOS_MAKE_PATH)/tweak.mk