# المعماريات المدعومة
ARCHS = arm64 arm64e
DEBUG = 0
FINALPACKAGE = 1

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = DooN_Wizard

# ملفات المشروع
DooN_Wizard_FILES = Tweak.x

# إدراج المكتبات الرسومية اللازمة للألوان والدوائر المتوهجة والكرة الشبح
DooN_Wizard_FRAMEWORKS = UIKit CoreGraphics QuartzCore Foundation

# ربط التويك بمحرك السبرايت (Substrate) لضمان الحقن الصحيح
DooN_Wizard_LIBRARIES = substrate

# إعدادات الكومبيلر
DooN_Wizard_CFLAGS = -fobjc-arc -Wno-error

include $(THEOS_MAKE_PATH)/tweak.mk
