#import <UIKit/UIKit.h>
#import <substrate.h>

// --- إعدادات التويك (يمكن ربطها بقائمة Preferences لاحقاً) ---
static bool kEnabled = YES;
static bool kAutoPlay = YES;

// تعريف الكلاس الأصلي كما ظهر في تحليل المكتبة
@interface TrajectoryManager : NSObject
@property (nonatomic, assign) int m_ballId;      // معرف الكرة الحالية
@property (nonatomic, assign) float m_finalX;    // إحداثي النهاية X
@property (nonatomic, assign) float m_finalY;    // إحداثي النهاية Y
@property (nonatomic, assign) bool m_autoPlayEnabled; 
- (int)getPredictedPocketId;                     // جلب رقم الجيب المتوقع
- (CGPoint)getPocketPosition:(int)index;         // جلب موقع الجيب برقم المعرف
@end

%hook TrajectoryManager

// 1. تفعيل الخصائص عند بداية التشغيل
- (id)init {
    self = %orig;
    if (self && kEnabled) {
        // تفعيل الأوتو بلاي داخلياً
        if (kAutoPlay) {
            MSHookIvar<bool>(self, "m_autoPlayEnabled") = YES;
        }
    }
    return self;
}

// 2. تعديل رسم المسارات وإضافة "الكرة الشبح"
- (void)drawPathWithContext:(CGContextRef)context {
    if (!kEnabled) return %orig;

    // الحصول على لون الكرة الحالية لتوحيد الرسم
    int ballId = MSHookIvar<int>(self, "m_ballId");
    UIColor *ballColor = [self colorForBall:ballId];

    // تغيير لون الخط الأصلي
    CGContextSetStrokeColorWithColor(context, ballColor.CGColor);
    CGContextSetLineWidth(context, 2.0);
    
    %orig; // رسم الخط

    // إضافة "الكرة الشبح" (Ghost Ball) في نهاية المسار
    float lastX = MSHookIvar<float>(self, "m_finalX");
    float lastY = MSHookIvar<float>(self, "m_finalY");
    [self drawGhostBallAt:CGPointMake(lastX, lastY) color:ballColor context:context];
}

// 3. إضافة دوائر الجيوب (أحمر/أخضر)
- (void)updateVisuals:(CGContextRef)context {
    %orig;
    if (!kEnabled) return;

    // جلب معرف الجيب الذي ستدخل فيه الكرة
    int targetPocket = [self getPredictedPocketId];

    for (int i = 0; i < 6; i++) {
        CGPoint pocketPos = [self getPocketPosition:i];
        
        // إذا كان الجيب هو المستهدف نجعله أخضر، وإلا أحمر
        UIColor *statusColor = (i == targetPocket) ? [UIColor greenColor] : [UIColor redColor];
        
        [self renderPocketCircle:pocketPos color:statusColor context:context];
    }
}

// --- دوال الرسم المساعدة الجديدة ---

%new
- (void)drawGhostBallAt:(CGPoint)point color:(UIColor *)color context:(CGContextRef)context {
    CGFloat radius = 12.0; // مقاس الكرة
    CGRect rect = CGRectMake(point.x - radius, point.y - radius, radius * 2, radius * 2);

    CGContextSetStrokeColorWithColor(context, [color colorWithAlphaComponent:0.8].CGColor);
    CGContextSetFillColorWithColor(context, [color colorWithAlphaComponent:0.2].CGColor);
    CGContextSetLineWidth(context, 1.5);

    CGContextFillEllipseInRect(context, rect);
    CGContextStrokeEllipseInRect(context, rect);
}

%new
- (void)renderPocketCircle:(CGPoint)point color:(UIColor *)color context:(CGContextRef)context {
    CGFloat radius = 18.0;
    CGRect rect = CGRectMake(point.x - radius, point.y - radius, radius * 2, radius * 2);

    CGContextSetShadowWithColor(context, CGSizeMake(0, 0), 10.0, color.CGColor);
    CGContextSetStrokeColorWithColor(context, color.CGColor);
    CGContextSetLineWidth(context, 3.5);
    
    CGContextStrokeEllipseInRect(context, rect);
}

%new
- (UIColor *)colorForBall:(int)bid {
    if (bid == 0) return [UIColor whiteColor]; // الكرة البيضاء
    if (bid == 8) return [UIColor blackColor]; // الكرة السوداء
    
    // مصفوفة الألوان لبقية الكرات
    NSArray *colors = @[
        [UIColor yellowColor], [UIColor blueColor], [UIColor redColor],
        [UIColor purpleColor], [UIColor orangeColor], [UIColor greenColor], [UIColor brownColor]
    ];
    return colors[(bid - 1) % 7];
}

%end
