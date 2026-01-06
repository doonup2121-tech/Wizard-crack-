# المعماريات المدعومة (إجبار arm64 فقط لحل مشكلة IMG_1133)
ARCHS = arm64
TARGET = iphone:clang:latest:14.0

TWEAK_NAME = DooN_Wizard
DooN_Wizard_FILES = Tweak.x

# المكتبات اللي اتفقنا عليها لكسر الحماية ومنع الـ Error
DooN_Wizard_FRAMEWORKS = UIKit Foundation Security CoreGraphics

# إعدادات الحماية والأداء
DooN_Wizard_CFLAGS = -fobjc-arc
DooN_Wizard_LDFLAGS = -Wl,-segalign,4000

# لضمان إن الملف يشتغل على النسخة النهائية
FINAL_PACKAGE = 1

include $(THEOS)/makefiles/common.mk
include $(THEOS_MAKE_PATH)/tweak.mk