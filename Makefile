# المعماريات المدعومة (arm64 للأجهزة الحديثة)
ARCHS = arm64 arm64e
DEBUG = 0
FINALPACKAGE = 1

# تحديد مسار الـ SDK إذا كنت تستخدم Theos على الويندوز أو الماك
TARGET = iphone:clang:latest:14.0

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = DooN_Wizard

# الملفات البرمجية (تأكد أن اسم الملف عندك Tweak.x أو Tweak.xm)
DooN_Wizard_FILES = Tweak.x

# إضافة المكتبات البرمجية المسؤولة عن الجرافيك والألوان
DooN_Wizard_FRAMEWORKS = UIKit CoreGraphics QuartzCore Foundation

# ربط التويك بمكتبة CydiaSubstrate لضمان عمل الـ Hooking
DooN_Wizard_LIBRARIES = substrate

DooN_Wizard_CFLAGS = -fobjc-arc -Wno-error

include $(THEOS_MAKE_PATH)/tweak.mk

# أمر بعد التثبيت (اختياري) لإعادة تشغيل الواجهة
after-install::
	install.exec "killall -9 SpringBoard"
