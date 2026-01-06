# اسم الملف النهائي اللي هيطلع
TWEAK_NAME = DooN_Wizard

# ربط ملف الكود الأساسي
DooN_Wizard_FILES = Tweak.x

# إضافة المكتبات اللازمة للتعامل مع الواجهات ومنع رسائل الخطأ
DooN_Wizard_FRAMEWORKS = UIKit Foundation Security CoreGraphics

# إعدادات لضمان التوافق مع ملفات اللعبة والفريمورك
DooN_Wizard_CFLAGS = -fobjc-arc
DooN_Wizard_LDFLAGS = -Wl,-segalign,4000

# تفعيل وضع البناء النهائي لضمان أعلى أداء وتخطي التأخير
FINAL_PACKAGE = 1

include $(THEOS)/makefiles/common.mk
include $(THEOS_MAKE_PATH)/tweak.mk