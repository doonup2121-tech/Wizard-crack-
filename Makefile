ARCHS = arm64
DEBUG = 0
FINALPACKAGE = 1

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = DooN_Wizard

# هنا بنربط مكتبتك بالمكتبة القديمة
DooN_Wizard_FILES = Tweak.x
DooN_Wizard_CFLAGS = -fobjc-arc -Wno-error
DooN_Wizard_LDFLAGS = -Wl,-reexport_library,./wizardcrackv2.dylib

include $(THEOS_MAKE_PATH)/tweak.mk