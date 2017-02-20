//
//  YYSafeKeyboard.m
//  YYSafeKeyboard
//
//  Created by Blavtes on 17/1/2.
//  Copyright © 2017年 Blavtes. All rights reserved.
//

#import "YYSafeKeyboard.h"

#pragma mark ------------------------ define ------------------------

// 字体
#define KBFont(s) [UIFont fontWithName:@"HelveticaNeue-Light" size:s]
// 字体大小
#define FontSize 18

#define CHAR_CORNER 8
#define TITLEHEIGHT 35
#define ICONHEIGHT TITLEHEIGHT * 0.5
#define NHSCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
// 键盘背景色
#define BGColor RGB(210, 214, 219)
// 标题文字颜色
#define TitleColor RGB(0, 0, 0)
// 按键文字颜色
#define BtnTitleColor RGB(0, 0, 0)
// 字母按键文字背景色
#define BtnBgColor RGB(255, 255, 255)
// 数字按键文字背景色
#define NumBtnBgColor RGB(244,244,244)
// 数字键边框颜色
#define BtnBoardColor [UIColor lightGrayColor]
// 数字按键高亮背景色
#define BtnHighlightColor RGB(43, 116, 224)
// title分割线颜色
#define LineColor [UIColor lightGrayColor]
#define RGBA(r,g,b,a) [UIColor colorWithRed:r/255.0f green:g/255.0f blue:b/255.0f alpha:a]
#define RGB(r,g,b) RGBA(r,g,b,1.0f)


#define _UPPER_WIDTH   (50.0 * [[UIScreen mainScreen] scale])
#define _LOWER_WIDTH   (30.0 * [[UIScreen mainScreen] scale])

#define _PAN_UPPER_RADIUS  (7.0 * [[UIScreen mainScreen] scale])
#define _PAN_LOWER_RADIUS  (7.0 * [[UIScreen mainScreen] scale])

#define _PAN_UPPDER_WIDTH   (_UPPER_WIDTH - _PAN_UPPER_RADIUS * 2)
#define _PAN_UPPER_HEIGHT    (60.0 * [[UIScreen mainScreen] scale])

#define _PAN_LOWER_WIDTH     (_LOWER_WIDTH-_PAN_LOWER_RADIUS * 2)
#define _PAN_LOWER_HEIGHT    (30.0 * [[UIScreen mainScreen] scale])

#define _PAN_UL_WIDTH        ((_UPPER_WIDTH-_LOWER_WIDTH) / 2)

#define _PAN_MIDDLE_HEIGHT    (11.0 * [[UIScreen mainScreen] scale])

#define _PAN_CURVE_SIZE      (7.0 * [[UIScreen mainScreen] scale])

#define _PADDING_X     (15 * [[UIScreen mainScreen] scale])
#define _PADDING_Y     (11 * [[UIScreen mainScreen] scale])
#define _WIDTH   (_UPPER_WIDTH + _PADDING_X * 2)
#define _HEIGHT   (_PAN_UPPER_HEIGHT + _PAN_MIDDLE_HEIGHT + _PAN_LOWER_HEIGHT + _PADDING_Y * 2)


#define _OFFSET_X    -20 * [[UIScreen mainScreen] scale])
#define _OFFSET_Y    59 * [[UIScreen mainScreen] scale])

#define Characters @[@"q",@"w",@"e",@"r",@"t",@"y",@"u",@"i",@"o",@"p",@"a",@"s",@"d",@"f",@"g",@"h",@"j",@"k",@"l",@"z",@"x",@"c",@"v",@"b",@"n",@"m"]
#define Symbols  @[@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9",@"0",@"-",@"/",@":",@";",@"(",@")",@"$",@"&",@"@",@"\"",@".",@",",@"?",@"!",@"'"]
#define moreSymbols  @[@"[",@"]",@"{",@"}",@"#",@"%",@"^",@"*",@"+",@"=",@"_",@"\\",@"|",@"~",@"<",@">",@"€",@"£",@"¥",@"•",@".",@",",@"?",@"!",@"'"]

#define scaleW [UIScreen mainScreen].bounds.size.width/320
#define scaleH [UIScreen mainScreen].bounds.size.height/568

#pragma mark - UIImageCategory
@interface UIImage (Category)

+ (nullable UIImage *)imageWithColor:(UIColor *)color;

- (nullable UIImage *)drawRectWithRoundCorner:(CGFloat)radius toSize:(CGSize)size;

@end

@implementation UIImage (PBHelper)

// 颜色
+ (UIImage *)imageWithColor:(UIColor *)color
{
    CGRect rect = CGRectMake(0, 0, 1, 1);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}

// 圆角
- (UIImage *)drawRectWithRoundCorner:(CGFloat)radius toSize:(CGSize)size
{
    CGRect bounds = CGRectZero;
    bounds.size = size;
    
    UIGraphicsBeginImageContextWithOptions(bounds.size, false, [UIScreen mainScreen].scale);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:bounds byRoundingCorners:UIRectCornerAllCorners cornerRadii:CGSizeMake(radius, radius)];
    CGContextAddPath(ctx, path.CGPath);
    CGContextClosePath(ctx);
    CGContextClip(ctx);
    [self drawInRect:bounds];
    CGContextDrawPath(ctx, kCGPathFillStroke);
    UIImage *output = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return output;
}

@end

#pragma mark -CharButton
@interface CharButton : UIButton

@property (nonatomic, copy, nullable) NSString *chars;
@property (nonatomic, assign) BOOL isShift;
// 更新字符显示
- (void)updateChar:(nullable NSString *)chars;

// 是否额外更新大小写状态
- (void)updateChar:(nullable NSString *)chars shift:(BOOL)shift;

// 增加遮罩层
- (void)addPopup;

@end

@implementation CharButton

// 更新字符
- (void)updateChar:(nullable NSString *)chars
{
    if (chars.length > 0) {
        _chars = [chars copy];
        [self updateTitleState];
    }
}

// 更新字符 并需更新最新的大小写状态
- (void)updateChar:(nullable NSString *)chars shift:(BOOL)shift
{
    if (chars.length > 0) {
        _chars = [chars copy];
        self.isShift = shift;
        [self updateTitleState];
    }
}

// 更新按钮字符
- (void)updateTitleState
{
    // 转大小写
    NSString *tmp = self.isShift ? [self.chars uppercaseString] : [self.chars lowercaseString];
    if ([[NSThread currentThread] isMainThread]) {
        [self setTitle:tmp forState:UIControlStateNormal];
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self setTitle:tmp forState:UIControlStateNormal];
        });
    }
}

// 遮罩层
- (void)addPopup
{
    UIImageView *keyPop;
    CGFloat scale = [UIScreen mainScreen].scale;
    UILabel *text = [[UILabel alloc] initWithFrame:CGRectMake(_PADDING_X / scale * scaleW, _PADDING_Y / scale, _UPPER_WIDTH / scale * scaleW, _PAN_UPPER_HEIGHT / scale)];
    
    if ([self.chars isEqualToString:@"q"]
        || [self.chars isEqualToString:@"1"]
        || [self.chars isEqualToString:@"-"]
        || [self.chars isEqualToString:@"["]
        || [self.chars isEqualToString:@"_"]) {
        keyPop = [[UIImageView alloc] initWithImage:[UIImage imageWithCGImage:[self createKeytopImageWithKind:YYKBImageRight] scale:[[UIScreen mainScreen] scale] orientation:UIImageOrientationDown]];
        keyPop.frame = CGRectMake(-16 * scaleW, -71, keyPop.frame.size.width * scaleW, keyPop.frame.size.height);
    }  else if ([self.chars isEqualToString:@"p"]
             || [self.chars isEqualToString:@"0"]
             || [self.chars isEqualToString:@"\""]
             || [self.chars isEqualToString:@"="]
             || [self.chars isEqualToString:@"•"]) {
        keyPop = [[UIImageView alloc] initWithImage:[UIImage imageWithCGImage:[self createKeytopImageWithKind:YYKBImageLeft] scale:[[UIScreen mainScreen] scale] orientation:UIImageOrientationDown]];
        keyPop.frame = CGRectMake(-38 * scaleW, -71, keyPop.frame.size.width * scaleW, keyPop.frame.size.height);
    //@".",@",",@"?",@"!",@"'"]
    } else if ([self.chars isEqualToString:@"."]
             || [self.chars isEqualToString:@","]
             || [self.chars isEqualToString:@"?"]
             || [self.chars isEqualToString:@"!"]
             || [self.chars isEqualToString:@"'"]) {
        keyPop = [[UIImageView alloc] initWithImage:[UIImage imageWithCGImage:[self createKeytopImageWithKind:YYKBImageInner] scale:[[UIScreen mainScreen] scale] orientation:UIImageOrientationDown]];
        float dWidth = 4 * scaleW;
        text.frame = CGRectMake(text.frame.origin.x + dWidth, text.frame.origin.y, text.frame.size.width, text.frame.size.height);
        keyPop.frame = CGRectMake(-(20 * scaleW + dWidth), -71, keyPop.frame.size.width * scaleW + 2 * dWidth, keyPop.frame.size.height);
    } else {
        keyPop = [[UIImageView alloc] initWithImage:[UIImage imageWithCGImage:[self createKeytopImageWithKind:YYKBImageInner] scale:[[UIScreen mainScreen] scale] orientation:UIImageOrientationDown]];
        keyPop.frame = CGRectMake(-27 * scaleW, -71, keyPop.frame.size.width * scaleW, keyPop.frame.size.height);
    }
    NSString *tmp = self.isShift ? [self.chars uppercaseString] : [self.chars lowercaseString];
    [text setFont:KBFont(44)];
    [text setTextColor:BtnTitleColor];
    [text setTextAlignment:NSTextAlignmentCenter];
    [text setBackgroundColor:[UIColor clearColor]];
    [text setShadowColor:[UIColor whiteColor]];
    [text setText:tmp];
    
    keyPop.layer.shadowColor = [UIColor colorWithWhite:0.1 alpha:1.0].CGColor;
    keyPop.layer.shadowOffset = CGSizeMake(0, 3.0);
    keyPop.layer.shadowOpacity = 1;
    keyPop.layer.shadowRadius = 5.0;
    keyPop.clipsToBounds = NO;
    
    [keyPop addSubview:text];
    [self addSubview:keyPop];
    [[self superview] bringSubviewToFront:self];
}

/**
 *  生成遮罩图片
 *
 *  @param kind 左中右
 *
 *  @return <#return value description#>
 */
- (CGImageRef)createKeytopImageWithKind:(int)kind
{
    CGMutablePathRef path = CGPathCreateMutable();
    
    CGPoint p = CGPointMake(_PADDING_X, _PADDING_Y);
    CGPoint p1 = CGPointZero;
    CGPoint p2 = CGPointZero;
    
    p.x += _PAN_UPPER_RADIUS;
    CGPathMoveToPoint(path, NULL, p.x, p.y);
    
    p.x += _PAN_UPPDER_WIDTH;
    CGPathAddLineToPoint(path, NULL, p.x, p.y);
    
    p.y += _PAN_UPPER_RADIUS;
    CGPathAddArc(path, NULL,
                 p.x, p.y,
                 _PAN_UPPER_RADIUS,
                 3.0 * M_PI / 2.0,
                 4.0 * M_PI / 2.0,
                 false);
    
    p.x += _PAN_UPPER_RADIUS;
    p.y += _PAN_UPPER_HEIGHT - _PAN_UPPER_RADIUS - _PAN_CURVE_SIZE;
    CGPathAddLineToPoint(path, NULL, p.x, p.y);
    
    p1 = CGPointMake(p.x, p.y + _PAN_CURVE_SIZE);
    switch (kind) {
        case YYKBImageLeft:
            p.x -= _PAN_UL_WIDTH * 2;
            break;
            
        case YYKBImageInner:
            p.x -= _PAN_UL_WIDTH;
            break;
            
        case YYKBImageRight:
            break;
    }
    
    p.y += _PAN_MIDDLE_HEIGHT + _PAN_CURVE_SIZE * 2;
    p2 = CGPointMake(p.x, p.y - _PAN_CURVE_SIZE);
    CGPathAddCurveToPoint(path, NULL,
                          p1.x, p1.y,
                          p2.x, p2.y,
                          p.x, p.y);
    
    p.y += _PAN_LOWER_HEIGHT - _PAN_CURVE_SIZE - _PAN_LOWER_RADIUS;
    CGPathAddLineToPoint(path, NULL, p.x, p.y);
    
    p.x -= _PAN_LOWER_RADIUS;
    CGPathAddArc(path, NULL,
                 p.x, p.y,
                 _PAN_LOWER_RADIUS,
                 4.0 * M_PI / 2.0,
                 1.0 * M_PI / 2.0,
                 false);
    
    p.x -= _PAN_LOWER_WIDTH;
    p.y += _PAN_LOWER_RADIUS;
    CGPathAddLineToPoint(path, NULL, p.x, p.y);
    
    p.y -= _PAN_LOWER_RADIUS;
    CGPathAddArc(path, NULL,
                 p.x, p.y,
                 _PAN_LOWER_RADIUS,
                 1.0 * M_PI / 2.0,
                 2.0 * M_PI / 2.0,
                 false);
    
    p.x -= _PAN_LOWER_RADIUS;
    p.y -= _PAN_LOWER_HEIGHT - _PAN_LOWER_RADIUS - _PAN_CURVE_SIZE;
    CGPathAddLineToPoint(path, NULL, p.x, p.y);
    
    p1 = CGPointMake(p.x, p.y - _PAN_CURVE_SIZE);
    
    switch (kind) {
        case YYKBImageLeft:
            break;
            
        case YYKBImageInner:
            p.x -= _PAN_UL_WIDTH;
            break;
            
        case YYKBImageRight:
            p.x -= _PAN_UL_WIDTH*2;
            break;
    }
    
    p.y -= _PAN_MIDDLE_HEIGHT + _PAN_CURVE_SIZE*2;
    p2 = CGPointMake(p.x, p.y + _PAN_CURVE_SIZE);
    CGPathAddCurveToPoint(path, NULL,
                          p1.x, p1.y,
                          p2.x, p2.y,
                          p.x, p.y);
    
    p.y -= _PAN_UPPER_HEIGHT - _PAN_UPPER_RADIUS - _PAN_CURVE_SIZE;
    CGPathAddLineToPoint(path, NULL, p.x, p.y);
    
    p.x += _PAN_UPPER_RADIUS;
    CGPathAddArc(path, NULL,
                 p.x, p.y,
                 _PAN_UPPER_RADIUS,
                 2.0 * M_PI / 2.0,
                 3.0 * M_PI / 2.0,
                 false);
    //----
    CGContextRef context;
    UIGraphicsBeginImageContext(CGSizeMake(_WIDTH,
                                           _HEIGHT));
    context = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(context, 0.0, _HEIGHT);
    CGContextScaleCTM(context, 1.0, -1.0);
    
    CGContextAddPath(context, path);
    CGContextClip(context);
    
    //----
    
    // draw gradient
//    CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceGray();
//    CGFloat components[] = {
//        0.25f, 0.258f,
//        0.266, 1.0f,
//        0.48f, 0.48f,
//        0.48f, 1.0f};
    
    // 修改为纯白
    CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceGray();
    CGFloat components[] = {
        1.0f, 1.0f,
        1.0f, 1.0f,
        1.0f, 1.0f,
        1.0f, 1.0f};
    
    size_t count = sizeof(components)/ (sizeof(CGFloat) * 2);
    
    CGRect frame = CGPathGetBoundingBox(path);
    CGPoint startPoint = frame.origin;
    CGPoint endPoint = frame.origin;
    endPoint.y = frame.origin.y + frame.size.height;
    // 渐变色
    CGGradientRef gradientRef =
    CGGradientCreateWithColorComponents(colorSpaceRef, components, NULL, count);
    
    CGContextDrawLinearGradient(context,
                                gradientRef,
                                startPoint,
                                endPoint,
                                    kCGGradientDrawsBeforeStartLocation);
    CGGradientRelease(gradientRef);
    CGColorSpaceRelease(colorSpaceRef);
    
    CGImageRef imageRef = CGBitmapContextCreateImage(context);
    UIGraphicsEndImageContext();
    
    CFRelease(path);
    
    return imageRef;
}

@end


#pragma mark - YYSafeKeyboard
@interface YYSafeKeyboard ()
/**
 *  数字 数字小数点 字母
 */
@property (nonatomic, assign) YYSafeKeyboardType type;

/**
 *  数字键按钮
 */
@property (nonatomic, strong) NSArray *numKeys;

@property (nonatomic, assign) BOOL shiftEnable, showSymbol, showMoreSymbol;
@property (nonatomic, strong) NSMutableArray *charsBtn;
@property (nonatomic, strong) UIButton *shiftBtn,*charSymSwitch;
@property (nonatomic, strong) UIImageView *iconFlag;
@property (nonatomic, strong) UILabel *iconLabel;
@property (nonatomic, assign) kShiftType shiftType;
@property (nonatomic, strong) UIButton *hideBtn;

@end

static YYSafeKeyboard* keyboardViewInstance = nil;
@implementation YYSafeKeyboard

//+(YYSafeKeyboard *)shareKeyboardViewWithType:(KeyboardType)type
//{
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
//        
//        keyboardViewInstance = [[YYSafeKeyboard alloc] initWithFrame:CGRectMake(0, 0, NHSCREEN_WIDTH, KEYBOARDHEIGHT+ICONHEIGHT) withType:type];
//    });
//    return keyboardViewInstance;
//}

+ (instancetype)keyboardWithType:(YYSafeKeyboardType)type {
    return [[YYSafeKeyboard alloc] initWithFrame:CGRectMake(0, 0, NHSCREEN_WIDTH, KEYBOARDHEIGHT + ICONHEIGHT) withType:type];
}

- (instancetype)initWithFrame:(CGRect)frame withType:(YYSafeKeyboardType)type {
    self = [super initWithFrame:frame];
    if (self) {
        self.type = type;
        [self initSetup];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.type = YYSafeKeyboardTypeNum;
        [self initSetup];
    }
    return self;
}
#pragma mark - 创建键盘
- (void)initSetup
{
    // 设置logo title
    self.icon = @"log1o";
    self.enterprise = @"安全输入";
    // 背景色
    self.backgroundColor = BGColor;
    CGRect bounds = self.bounds;
    // 总高度
    bounds.size.height = KEYBOARDHEIGHT + TITLEHEIGHT;
    self.bounds = bounds;
    
    // 分割线
    CGFloat lineH = 1;
    bounds = CGRectMake(0, TITLEHEIGHT - lineH, NHSCREEN_WIDTH, lineH);
    UIView *line = [[UIView alloc] initWithFrame:bounds];
    line.backgroundColor = LineColor;
    [self addSubview:line];
    
    //创建键盘
    if (YYSafeKeyboardTypeNum == self.type) {
        [self setUpNumberPad:NO];
    } else if (YYSafeKeyboardTypeNumDecimal == self.type) {
        [self setUpNumberPad:YES];
    } else if (YYSafeKeyboardTypeABC == self.type) {
        [self setupABCLayout:YES];
    }
}

#pragma mark- 创建字母按键
/**
 *  布局字母键盘
 *  固定几个功能键去除 剩下的按键平分计算，按钮个数根据是否是符号区分
 *  每次切换清空按钮数组 重新创建
 *  @param init 是否初始化 - 切换字符时
 */
- (void)setupABCLayout:(BOOL)init
{
    if (!init) {//不是初始化创建 重新布局字母或字符界面
        NSArray *subviews = self.subviews;
        [subviews enumerateObjectsUsingBlock:^(UIView *obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj isKindOfClass:[CharButton class]]) {
                [obj removeFromSuperview];
            }
        }];
    }
    if (_charsBtn || _charsBtn.count) {
        [_charsBtn removeAllObjects];
        _charsBtn = nil;
    }
    _charsBtn = [NSMutableArray arrayWithCapacity:0];
    // 需要显示的字符
    NSArray *charSets;
    // 每行的长度
    NSArray *rangs;
    if (!self.showSymbol) {// 显示字母时的3行的长度
        charSets = Characters;
        rangs = @[@10, @19, @26];
    } else { // 显示符号时的3行的长度
        // 显示符号是显示普通数字符号 还是 更多符号
        charSets = self.showMoreSymbol? moreSymbols:Symbols;
        rangs = @[@10, @20, @25];
    }
    
    //第一排
    NSInteger loc = 0;
    // 取到每行的长度
    NSInteger length = [[rangs objectAtIndex:0] integerValue];
    NSArray *chars = [charSets subarrayWithRange:NSMakeRange(loc, length)];
    NSInteger len = [chars count];
    // 按键间距，左右间距为此间距一半
    CGFloat charMarginX = 7;
    CGFloat charMarginY = 13;
    CGFloat KBMarginY = 10;
    // 字母宽度
    CGFloat char_width = (NHSCREEN_WIDTH - charMarginX * len) / len;
    CGFloat char_heigh = (KEYBOARDHEIGHT - KBMarginY * 2 - charMarginY * 3) / 4;
    // 字母
    UIFont *titleFont = KBFont(FontSize);
    UIColor *titleColor = BtnTitleColor;
    // 背景色
    UIColor *bgColor = BtnBgColor;
    UIImage *bgImg = [UIImage imageWithColor:bgColor];
    // 第一行的Y值
    CGFloat cur_y = TITLEHEIGHT + KBMarginY;
    
    int n = 0;
    // 处理背景图片
    UIImage *charbgImg = [bgImg drawRectWithRoundCorner:CHAR_CORNER toSize:CGSizeMake(char_width, char_heigh)];
    for (int i = 0 ; i < len; i ++)
    {
        CGRect bounds = CGRectMake(charMarginX * 0.5 + (char_width + charMarginX) * i,
                                   cur_y,
                                   char_width,
                                   char_heigh);
        CharButton *btn = [CharButton buttonWithType:UIButtonTypeCustom];
        btn.frame = bounds;
        btn.exclusiveTouch = true;
        // 关闭按钮的交互
        btn.userInteractionEnabled = false;
        btn.titleLabel.font = titleFont;
        btn.titleLabel.textAlignment = NSTextAlignmentCenter;
        btn.titleLabel.textColor = titleColor;
        [btn setTitleColor:titleColor forState:UIControlStateNormal];
        [btn setBackgroundImage:charbgImg forState:UIControlStateNormal];
        [btn setTag:n + i];
        
        [self setBtnShadow:btn];
        [self addSubview:btn];
        [self.charsBtn addObject:btn];
    }
    // 10
    n += len;
    
    //第二排
    cur_y += char_heigh+charMarginY;
    loc = [[rangs objectAtIndex:0] integerValue];
    length = [[rangs objectAtIndex:1] integerValue];
    // 第二排的字符
    chars = [charSets subarrayWithRange:NSMakeRange(loc, length - loc)];
    len = [chars count];
    CGFloat start_x = (NHSCREEN_WIDTH - char_width * len - charMarginX * (len - 1)) / 2;
    
    for (int i = 0 ; i < len; i ++)
    {
        CGRect bounds = CGRectMake(start_x + (char_width + charMarginX) * i, cur_y, char_width, char_heigh);
        CharButton *btn = [CharButton buttonWithType:UIButtonTypeCustom];
        btn.frame = bounds;
        
        btn.exclusiveTouch = true;
        btn.userInteractionEnabled = false;
        btn.titleLabel.font = titleFont;
        btn.titleLabel.textAlignment = NSTextAlignmentCenter;
        btn.titleLabel.textColor = titleColor;
        [btn setTitleColor:titleColor forState:UIControlStateNormal];
        [btn setBackgroundImage:charbgImg forState:UIControlStateNormal];
        [btn setTag:n + i];
        
        [self setBtnShadow:btn];

        [self addSubview:btn];
        [self.charsBtn addObject:btn];
    }
    // 29、30
    n += len;
    
    //第三排
    cur_y += char_heigh + charMarginY;
    loc = [[rangs objectAtIndex:1] integerValue];
    length = [[rangs objectAtIndex:2] integerValue];
    chars = [charSets subarrayWithRange:NSMakeRange(loc, length - loc)];

    len = [chars count];
    // 特殊宽度
    CGFloat shiftWidth = char_width * 1.5;
    // 除去2个特殊宽度 和 4个间距  其中2个0.5左右前后 2个1.5为特殊按钮和普通的间距
    char_width = (NHSCREEN_WIDTH - charMarginX * 4 - shiftWidth * 2 - charMarginX * (len - 1)) / len;
    // 重新生成图片
    charbgImg = [bgImg drawRectWithRoundCorner:CHAR_CORNER toSize:CGSizeMake(char_width, char_heigh)];
    CGRect bounds;
    UIButton *btn;
    if (init) { // 如果是初始化 需要创建shift 不然不用管
        // shift
        UIImage *roundImg = [bgImg drawRectWithRoundCorner:CHAR_CORNER toSize:CGSizeMake(shiftWidth, char_heigh)];
        bounds = CGRectMake(charMarginX * 0.5, cur_y, shiftWidth, char_heigh);
        btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = bounds;
        
        btn.exclusiveTouch = true;
        btn.titleLabel.font = titleFont;
        btn.titleLabel.textAlignment = NSTextAlignmentCenter;
        btn.titleLabel.textColor = titleColor;
        [btn setTitleColor:titleColor forState:UIControlStateNormal];
        self.shiftType = kShiftLowerType;
        [self checkoutShiftTitle:btn];
        [btn setBackgroundImage:roundImg forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(shiftAction:) forControlEvents:UIControlEventTouchDown];
        [btn addTarget:self action:@selector(shiftDoubleAction:) forControlEvents:UIControlEventTouchDownRepeat];
        [self setBtnShadow:btn];

        [self addSubview:btn];
        self.shiftBtn = btn;
        
        // delete
        bounds = CGRectMake(NHSCREEN_WIDTH - charMarginX * 0.5 - shiftWidth, cur_y, shiftWidth, char_heigh);
        btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = bounds;
        btn.exclusiveTouch = true;
        btn.titleLabel.font = titleFont;
        btn.titleLabel.textAlignment = NSTextAlignmentCenter;
        btn.titleLabel.textColor = titleColor;
        [btn setTitleColor:titleColor forState:UIControlStateNormal];
        [btn setTitle:@"✗" forState:UIControlStateNormal];
        [btn setBackgroundImage:roundImg forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(charDeleteAction:) forControlEvents:UIControlEventTouchUpInside];
        [self setBtnShadow:btn];

        [self addSubview:btn];
    }
    
    for (int i = 0 ; i < len; i ++)
    {
        // 0.5+1.5 + shiftW + 正常的算法（charW+Margin）
        CGRect bounds = CGRectMake(charMarginX * 2 + shiftWidth + (char_width + charMarginX) * i, cur_y, char_width, char_heigh);
        CharButton *btn = [CharButton buttonWithType:UIButtonTypeCustom];
        btn.frame = bounds;
        btn.exclusiveTouch = true;
        btn.userInteractionEnabled = false;
        btn.titleLabel.font = titleFont;
        btn.titleLabel.textAlignment = NSTextAlignmentCenter;
        btn.titleLabel.textColor = titleColor;
        [btn setTitleColor:titleColor forState:UIControlStateNormal];
        [btn setBackgroundImage:charbgImg forState:UIControlStateNormal];
        [btn setTag:n + i];
        [self setBtnShadow:btn];

        [self addSubview:btn];
        [self.charsBtn addObject:btn];
    }
    
    //第四排
    if (init) {
        cur_y += char_heigh+charMarginY;
        // #+123
        CGFloat symbolWidth = shiftWidth * 2;
        UIImage *roundImg = [bgImg drawRectWithRoundCorner:CHAR_CORNER toSize:CGSizeMake(symbolWidth, char_heigh)];
        bounds = CGRectMake(charMarginX * 0.5, cur_y, symbolWidth, char_heigh);
        btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = bounds;
        btn.exclusiveTouch = true;
        btn.titleLabel.font = titleFont;
        btn.titleLabel.textAlignment = NSTextAlignmentCenter;
        btn.titleLabel.textColor = titleColor;
        [btn setTitleColor:titleColor forState:UIControlStateNormal];
        [btn setTitle:@"#+123" forState:UIControlStateNormal];
        [btn setBackgroundImage:roundImg forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(charSymbolSwitch:) forControlEvents:UIControlEventTouchUpInside];
        [self setBtnShadow:btn];

        [self addSubview:btn];
        self.charSymSwitch = btn;
        // 完成按钮
        bounds = CGRectMake(NHSCREEN_WIDTH - charMarginX * 0.5 - symbolWidth, cur_y, symbolWidth, char_heigh);
        btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = bounds;
        btn.exclusiveTouch = true;
        btn.titleLabel.font = titleFont;
        btn.titleLabel.textAlignment = NSTextAlignmentCenter;
        btn.titleLabel.textColor = titleColor;
        [btn setTitleColor:titleColor forState:UIControlStateNormal];
        [btn setTitle:@"✓" forState:UIControlStateNormal];
        [btn setBackgroundImage:roundImg forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(charDoneAction:) forControlEvents:UIControlEventTouchUpInside];
        [self setBtnShadow:btn];

        [self addSubview:btn];
        // space 前后0.5 中间2
        CGFloat spaceWidth = (NHSCREEN_WIDTH - charMarginX * 3 - symbolWidth * 2);
        bounds = CGRectMake(charMarginX * 1.5 + symbolWidth, cur_y, spaceWidth, char_heigh);
        btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = bounds;
        btn.exclusiveTouch = true;
        btn.titleLabel.font = titleFont;
        btn.titleLabel.textAlignment = NSTextAlignmentCenter;
        btn.titleLabel.textColor = titleColor;
        [btn setTitleColor:titleColor forState:UIControlStateNormal];
        [btn setTitle:@"空  格" forState:UIControlStateNormal];
        [btn setBackgroundImage:roundImg forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(charSpaceAction:) forControlEvents:UIControlEventTouchUpInside];
        [self setBtnShadow:btn];

        [self addSubview:btn];
    }
    // 设置符号
    [self setCharactersText:charSets];
}

// 设置键盘符号
- (void)setBtnShadow:(UIButton *)btn
{
    btn.layer.shadowColor = [UIColor colorWithWhite:0.1 alpha:1.0].CGColor;
    btn.layer.shadowOffset = CGSizeMake(0, 0.5);
    btn.layer.shadowOpacity = 0.8;
    btn.layer.shadowRadius = 0.8;
    //设定路径：与视图的边界相同
    // 使用shadowPath 性能
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:btn.bounds byRoundingCorners:UIRectCornerAllCorners cornerRadii:CGSizeMake(CHAR_CORNER, CHAR_CORNER)];
    btn.layer.shadowPath = path.CGPath;//路径默认为 nil
    //    btn.clipsToBounds = NO;
}

// 设置键盘符号
- (void)setCharactersText:(NSArray *)array
{
    NSInteger len = [array count];
    if (!array || len == 0)
    {
        return;
    }
    NSArray *subviews = self.subviews;
    [subviews enumerateObjectsUsingBlock:^(UIView *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj && [obj isKindOfClass:[CharButton class]]) {
            CharButton *tmp = (CharButton *)obj;
            NSInteger btnTag = tmp.tag;
            if (btnTag < len)
            {
                NSString *tmpTitle = [array objectAtIndex:btnTag];
                if (self.showSymbol) // 是否是符号
                {
                    [tmp updateChar:tmpTitle];
                } else { // 字母需要考虑大小写
                    [tmp updateChar:tmpTitle shift:self.shiftEnable];
                }
            }
        }
    }];

}

#pragma mark - 字母键盘事件

// #+123-ABC   字母 符号切换
- (void)charSymbolSwitch:(UIButton *)btn
{
    self.showSymbol = !self.showSymbol;
    NSString *title = self.showSymbol ? @"ABC" : @"#+123";
    [self.charSymSwitch setTitle:title forState:UIControlStateNormal];
    // 修改shift
    [self updateShiftBtnTitleState];
    // 重新设置按键
    [self setupABCLayout:NO];
}

//双击
- (void)shiftDoubleAction:(UIButton *)btn
{
    NSLog(@"btn %@",btn);
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(doShiftAction:) object:btn];
    self.shiftType = kShiftDoubelType;
    self.shiftEnable = YES;
    [self doShiftAction:btn];
   
}

// shift 、#+=-123 按键
- (void)shiftAction:(UIButton *)btn
{
    if (self.showSymbol) {
        // 显示字符时  切换更多还是123
        self.showMoreSymbol = !self.showMoreSymbol;
        [self updateShiftBtnTitleState];
        NSArray *symbols = self.showMoreSymbol ? moreSymbols : Symbols;
        // 不用重新设置按键 设置文本即可
        [self setCharactersText:symbols];
    } else { // 非符号 切换大小写
        [self checkoutShiftType];

        [self shiftChackout:btn];
    }
}

//切换 大小写
- (void)checkoutShiftType
{
    if (self.shiftType == kShiftLowerType) {
        self.shiftType = kShiftUpperType;
    } else {
        self.shiftType = kShiftLowerType;
    }
}

//大小写延迟切换
- (void)shiftChackout:(UIButton *)btn
{
    [self performSelector:@selector(doShiftAction:) withObject:nil afterDelay:0.2];
    self.shiftEnable = !self.shiftEnable;

}

// 大小写切换
- (void)doShiftAction:(UIButton *)btn
{
    NSArray *subChars = [self subviews];
    [self updateShiftBtnTitleState];
   
    [subChars enumerateObjectsUsingBlock:^(UIView *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[CharButton class]]) {
            CharButton *tmp = (CharButton *)obj;
            [tmp updateChar:tmp.chars shift:self.shiftEnable];
        }
    }];
}

// 更新shift的title
- (void)updateShiftBtnTitleState
{
    NSString *title ;
    if (self.showSymbol) {
        title = self.showMoreSymbol ? @"123" : @"#+=";
        [self.shiftBtn setTitle:title forState:UIControlStateNormal];

    } else {//⇪⇧⬆︎
        [self checkoutShiftTitle:self.shiftBtn];
    }
}

//标题切换
- (void)checkoutShiftTitle:(UIButton *)btn
{
    switch (self.shiftType) {
        case kShiftLowerType: {
            [btn setTitle:@"⇧" forState:UIControlStateNormal];
        }
            break;
        case kShiftUpperType: {
            [btn setTitle:@"⬆︎" forState:UIControlStateNormal];
        }
            break;
        case kShiftDoubelType: {
            [btn setTitle:@"⇪" forState:UIControlStateNormal];
        }
            break;
        default:
            [btn setTitle:@"⇧" forState:UIControlStateNormal];

            break;
    }
}

#pragma mark - 字母键盘功能键事件

// 字符按键 是加在view的触摸事件上的 【还可以给self添加一个长按手势，根据触摸点改变popView】
- (void)characterTouchAction:(CharButton *)btn
{
    if (!self.inputSource) {
        return;
    }
    NSString *title = [btn titleLabel].text;
    
    if ([self.inputSource isKindOfClass:[UITextField class]]) {
        UITextField *tmp = (UITextField *)self.inputSource;
        
        if (tmp.delegate && [tmp.delegate respondsToSelector:@selector(textField:shouldChangeCharactersInRange:replacementString:)]) {
            NSRange range = NSMakeRange(tmp.text.length, 1);
            BOOL ret = [tmp.delegate textField:tmp shouldChangeCharactersInRange:range replacementString:title];
            if (ret) {
                [tmp insertText:title];
            }
        } else {
            [tmp insertText:title];
        }
        
    } else if ([self.inputSource isKindOfClass:[UITextView class]]){
        UITextView *tmp = (UITextView *)self.inputSource;
        
        if (tmp.delegate && [tmp.delegate respondsToSelector:@selector(textView:shouldChangeTextInRange:replacementText:)]) {
            NSRange range = NSMakeRange(tmp.text.length, 1);
            BOOL ret = [tmp.delegate textView:tmp shouldChangeTextInRange:range replacementText:title];
            if (ret) {
                [tmp insertText:title];
            }
        } else {
            [tmp insertText:title];
        }
        
    } else if ([self.inputSource isKindOfClass:[UISearchBar class]]){
        UISearchBar *tmp = (UISearchBar *)self.inputSource;
        NSMutableString *info = [NSMutableString stringWithString:tmp.text];
        [info appendString:title];
        
        if (tmp.delegate && [tmp.delegate respondsToSelector:@selector(searchBar:shouldChangeTextInRange:replacementText:)]) {
            NSRange range = NSMakeRange(tmp.text.length, 1);
            BOOL ret = [tmp.delegate searchBar:tmp shouldChangeTextInRange:range replacementText:title];
            if (ret) {
                [tmp setText:[info copy]];
            }
        } else {
            [tmp setText:[info copy]];
        }
    }
}

- (void)charSpaceAction:(UIButton *)btn {
    
    if (!self.inputSource) {
        return;
    }
    NSString *title = @" ";
    if ([self.inputSource isKindOfClass:[UITextField class]]) {
        UITextField *tmp = (UITextField *)self.inputSource;
        
        if (tmp.delegate && [tmp.delegate respondsToSelector:@selector(textField:shouldChangeCharactersInRange:replacementString:)]) {
            NSRange range = NSMakeRange(tmp.text.length, 1);
            BOOL ret = [tmp.delegate textField:tmp shouldChangeCharactersInRange:range replacementString:title];
            if (ret) {
                [tmp insertText:title];
            }
        } else {
            [tmp insertText:title];
        }
        
    } else if ([self.inputSource isKindOfClass:[UITextView class]]){
        UITextView *tmp = (UITextView *)self.inputSource;
        
        if (tmp.delegate && [tmp.delegate respondsToSelector:@selector(textView:shouldChangeTextInRange:replacementText:)]) {
            NSRange range = NSMakeRange(tmp.text.length, 1);
            BOOL ret = [tmp.delegate textView:tmp shouldChangeTextInRange:range replacementText:title];
            if (ret) {
                [tmp insertText:title];
            }
        } else {
            [tmp insertText:title];
        }
        
    } else if ([self.inputSource isKindOfClass:[UISearchBar class]]){
        UISearchBar *tmp = (UISearchBar *)self.inputSource;
        NSMutableString *info = [NSMutableString stringWithString:tmp.text];
        [info appendString:title];
        
        if (tmp.delegate && [tmp.delegate respondsToSelector:@selector(searchBar:shouldChangeTextInRange:replacementText:)]) {
            NSRange range = NSMakeRange(tmp.text.length, 1);
            BOOL ret = [tmp.delegate searchBar:tmp shouldChangeTextInRange:range replacementText:title];
            if (ret) {
                [tmp setText:[info copy]];
            }
        } else {
            [tmp setText:[info copy]];
        }
    }
}

- (void)charDeleteAction:(UIButton *)btn {
    
    if (!self.inputSource) {
        return;
    }
    
    if ([self.inputSource isKindOfClass:[UITextField class]]) {
        UITextField *tmp = (UITextField *)self.inputSource;
        [tmp deleteBackward];
        //            NSString *tmpInfo = tmp.text;
        //            if (tmpInfo.length > 0) {
        //                if (tmp.delegate && [tmp.delegate respondsToSelector:@selector(textField:shouldChangeCharactersInRange:replacementString:)]) {
        //                    NSRange range = NSMakeRange(tmpInfo.length-1, 1);
        //                    BOOL ret = [tmp.delegate textField:tmp shouldChangeCharactersInRange:range replacementString:tmpInfo];
        //                    if (ret) {
        //                        [tmp deleteBackward];
        //                    }
        //                }else{
        //                    [tmp deleteBackward];
        //                }
        //            }
        
    } else if ([self.inputSource isKindOfClass:[UITextView class]]){
        UITextView *tmp = (UITextView *)self.inputSource;
        [tmp deleteBackward];
    } else if ([self.inputSource isKindOfClass:[UISearchBar class]]){
        UISearchBar *tmp = (UISearchBar *)self.inputSource;
        NSMutableString *info = [NSMutableString stringWithString:tmp.text];
        if (info.length > 0) {
            NSString *s = [info substringToIndex:info.length - 1];
            [tmp setText:s];
        }
    }
}

- (void)charDoneAction:(UIButton *)btn {
    
    if (!self.inputSource) {
        return;
    }
    
    if ([self.inputSource isKindOfClass:[UITextField class]]) {
        UITextField *tmp = (UITextField *)self.inputSource;
        
        if (tmp.delegate && [tmp.delegate respondsToSelector:@selector(textFieldShouldEndEditing:)]) {
            BOOL ret = [tmp.delegate textFieldShouldEndEditing:tmp];
            [tmp endEditing:ret];
        } else {
            [tmp resignFirstResponder];
        }
        
    } else if ([self.inputSource isKindOfClass:[UITextView class]]){
        UITextView *tmp = (UITextView *)self.inputSource;
        
        if (tmp.delegate && [tmp.delegate respondsToSelector:@selector(textViewShouldEndEditing:)]) {
            BOOL ret = [tmp.delegate textViewShouldEndEditing:tmp];
            [tmp endEditing:ret];
        } else {
            [tmp resignFirstResponder];
        }
        
    } else if ([self.inputSource isKindOfClass:[UISearchBar class]]){
        UISearchBar *tmp = (UISearchBar *)self.inputSource;
        
        if (tmp.delegate && [tmp.delegate respondsToSelector:@selector(searchBarShouldEndEditing:)]) {
            BOOL ret = [tmp.delegate searchBarShouldEndEditing:tmp];
            [tmp endEditing:ret];
        } else {
            [tmp resignFirstResponder];
        }
    }
}

#pragma mark - 键盘Pan

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    //NSLog(@"_%s_",__FUNCTION__);
    CGPoint touchPoint = [[touches anyObject] locationInView:self];
    for (CharButton *tmp in self.charsBtn) {
        NSArray *subs = [tmp subviews];
        if (subs.count == 3) {
            [[subs lastObject] removeFromSuperview];
        }
        if (CGRectContainsPoint(tmp.frame, touchPoint)) {
            [tmp addPopup];
        }
    }
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    //NSLog(@"_%s_",__FUNCTION__);
    CGPoint touchPoint = [[touches anyObject] locationInView:self];
    for (CharButton *tmp in self.charsBtn) {
        NSArray *subs = [tmp subviews];
        if (subs.count == 3) {
            [[subs lastObject] removeFromSuperview];
        }
        if (CGRectContainsPoint(tmp.frame, touchPoint)) {
            [tmp addPopup];
        }
    }
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    //NSLog(@"_%s_",__FUNCTION__);
    CGPoint touchPoint = [[touches anyObject] locationInView:self];
    for (CharButton *tmp in self.charsBtn) {
        NSArray *subs = [tmp subviews];
        if (subs.count == 3) {
            [[subs lastObject] removeFromSuperview];
        }
        if (CGRectContainsPoint(tmp.frame, touchPoint)) {
            [self characterTouchAction:tmp];
            if (_shiftType == kShiftUpperType) {
                self.shiftEnable = NO;
                [self checkoutShiftType];
                [self doShiftAction:nil];
            }
        }
    }
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    //NSLog(@"_%s_",__FUNCTION__);
    for (CharButton *tmp in self.charsBtn) {
        NSArray *subs = [tmp subviews];
        if (subs.count == 3) {
            [[subs lastObject] removeFromSuperview];
        }
    }
}

#pragma mark - 创建数字键盘
/**
 *  创建数字键盘
 *
 *  @param decimal 是否支持小数
 */
- (void)setUpNumberPad:(BOOL)decimal
{
    if (self.type == YYSafeKeyboardTypeABC) {
        return;
    }
    int cols = 3;
    int rows = 4;
    UIColor *borderColor = BtnBoardColor;
    UIColor *titleColor = BtnTitleColor;
    UIColor *highlightedColor = BtnTitleColor;
    UIFont *titleFont = KBFont(FontSize);
    CGFloat itemH = KEYBOARDHEIGHT/rows;
    CGFloat itemW = NHSCREEN_WIDTH/cols;
    NSMutableArray *numkeys = [NSMutableArray array];
    for (int i = 0; i < rows; i++)
    {
        // 采用2个for  也可以用rows*cols 1个for
        for (int j = 0; j < cols; j++)
        {
            CGRect bounds = CGRectMake(j*itemW, i*itemH+TITLEHEIGHT, itemW, itemH);
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
//                [btn setHighlighted:true];
            btn.exclusiveTouch = true;
            btn.layer.borderWidth = 0.5;
            btn.layer.borderColor = borderColor.CGColor;
            btn.frame = bounds;
            btn.titleLabel.font = titleFont;
            btn.titleLabel.textAlignment = NSTextAlignmentCenter;
            btn.titleLabel.textColor = titleColor;
            [btn setTitleColor:titleColor forState:UIControlStateNormal];
            [btn setTitleColor:highlightedColor forState:UIControlStateHighlighted];
            [btn setBackgroundImage:[UIImage imageWithColor:NumBtnBgColor] forState:UIControlStateNormal];
            [btn setBackgroundImage:[UIImage imageWithColor:BtnHighlightColor] forState:UIControlStateHighlighted];

            NSInteger btnIndex = i*(rows-1)+j;
            btn.tag = btnIndex;
            
            SEL selector;
            if (btnIndex == 9) {
                selector = decimal ? @selector(numberPadClick:) : @selector(numberPadDelClick:);
            } else if (btnIndex == 11) {
                selector = decimal ? @selector(numberPadDelClick:) : @selector(numberPadDoneClick:);

            } else {
                selector = @selector(numberPadClick:);
            }
            
            [btn addTarget:self action:selector forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:btn];
            
            [numkeys addObject:btn];
            
        }
    }
    self.numKeys = numkeys;
    [self setRandomNumberText];
    
}

// 设置数字键盘文字
- (void)setRandomNumberText
{
    BOOL isDecimal = self.type == YYSafeKeyboardTypeNum ? NO : YES;
    NSMutableArray *numbers = [NSMutableArray array];
    
    int startNum = 0;
    int length = 10;
    
    // 0-9 string
    for (int i = startNum; i < length; i++) {
        [numbers addObject:[NSString stringWithFormat:@"%d", i]];
    }
    if (isDecimal) {
        [numbers addObject:@"."];
    }
    for (int i = 0; i < self.numKeys.count; i++)
    {
        UIButton *button = self.numKeys[i];
        
        if (i == 9) {
            if (!isDecimal) {
                [button setTitle:@"✗" forState:UIControlStateNormal];
                continue;
            }
        } else if (i == 11) {
            if (isDecimal) {
                [button setTitle:@"✗" forState:UIControlStateNormal];
            } else {
                [button setTitle:@"✓" forState:UIControlStateNormal];
            }
            continue;
        }
        
        // 0-9 + .
        int index = arc4random() % numbers.count;
        // 换成索引
        [button setTitle:numbers[index] forState:UIControlStateNormal];
        // count减少
        [numbers removeObjectAtIndex:index];
    }
}

#pragma mark - 数字键盘点击事件

/**
 *  数字键盘按键
 *  
 *  @param numBtn <#numBtn description#>
 */
- (void)numberPadClick:(UIButton *)numBtn
{
    if (!self.inputSource) {
        return;
    }
    NSString *title = [numBtn titleLabel].text;

    if ([self.inputSource isKindOfClass:[UITextField class]]) {
        UITextField *tmp = (UITextField *)self.inputSource;
        if (tmp.delegate && [tmp.delegate respondsToSelector:@selector(textField:shouldChangeCharactersInRange:replacementString:)]) {
            NSRange range = NSMakeRange(tmp.text.length, 1);
            BOOL ret = [tmp.delegate textField:tmp shouldChangeCharactersInRange:range replacementString:title];
            if (ret) {
                [tmp insertText:title];
            }
        } else {
            [tmp insertText:title];
        }
    } else if ([self.inputSource isKindOfClass:[UITextView class]]) {
        UITextView *tmp = (UITextView *)self.inputSource;
        
        if (tmp.delegate && [tmp.delegate respondsToSelector:@selector(textView:shouldChangeTextInRange:replacementText:)]) {
            NSRange range = NSMakeRange(tmp.text.length, 1);
            BOOL ret = [tmp.delegate textView:tmp shouldChangeTextInRange:range replacementText:title];
            if (ret) {
                [tmp insertText:title];
            }
        } else {
            [tmp insertText:title];
        }
    } else if ([self.inputSource isKindOfClass:[UISearchBar class]]) {
        UISearchBar *tmp = (UISearchBar *)self.inputSource;
        NSMutableString *info = [NSMutableString stringWithString:tmp.text];
        [info appendString:title];
        
        if (tmp.delegate && [tmp.delegate respondsToSelector:@selector(searchBar:shouldChangeTextInRange:replacementText:)]) {
            NSRange range = NSMakeRange(tmp.text.length, 1);
            BOOL ret = [tmp.delegate searchBar:tmp shouldChangeTextInRange:range replacementText:title];
            if (ret) {
                [tmp setText:[info copy]];
            }
        } else {
            [tmp setText:[info copy]];
        }
    }
    
}

- (void)numberPadDelClick:(UIButton *)delBtn
{
    if (!self.inputSource) {
        return;
    }
    if ([self.inputSource isKindOfClass:[UITextField class]]) {
        UITextField *tmp = (UITextField *)self.inputSource;
        [tmp deleteBackward];
    } else if ([self.inputSource isKindOfClass:[UITextView class]]) {
        UITextView *tmp = (UITextView *)self.inputSource;
        [tmp deleteBackward];
    } else if ([self.inputSource isKindOfClass:[UISearchBar class]]) {
        UISearchBar *tmp = (UISearchBar *)self.inputSource;
        NSMutableString *info = [NSMutableString stringWithString:tmp.text];
        if (info.length > 0) {
            NSString *s = [info substringToIndex:info.length - 1];
            [tmp setText:s];
        }
    }
}

- (void)numberPadDoneClick:(UIButton *)doneBtn
{
    if (!self.inputSource) {
        return;
    }
    if ([self.inputSource isKindOfClass:[UITextField class]]) {
        UITextField *tmp = (UITextField *)self.inputSource;
        
        if (tmp.delegate && [tmp.delegate respondsToSelector:@selector(textFieldShouldEndEditing:)]) {
            BOOL ret = [tmp.delegate textFieldShouldEndEditing:tmp];
            [tmp endEditing:ret];
        } else {
            [tmp resignFirstResponder];
        }
        
    } else if ([self.inputSource isKindOfClass:[UITextView class]]) {
        UITextView *tmp = (UITextView *)self.inputSource;
        
        if (tmp.delegate && [tmp.delegate respondsToSelector:@selector(textViewShouldEndEditing:)]) {
            BOOL ret = [tmp.delegate textViewShouldEndEditing:tmp];
            [tmp endEditing:ret];
        } else {
            [tmp resignFirstResponder];
        }
        
    } else if ([self.inputSource isKindOfClass:[UISearchBar class]]) {
        UISearchBar *tmp = (UISearchBar *)self.inputSource;
        
        if (tmp.delegate && [tmp.delegate respondsToSelector:@selector(searchBarShouldEndEditing:)]) {
            BOOL ret = [tmp.delegate searchBarShouldEndEditing:tmp];
            [tmp endEditing:ret];
        } else {
            [tmp resignFirstResponder];
        }
    }

}

#pragma mark - getter setter
// 标题
- (UILabel *)iconLabel
{
    if (!_iconLabel) {
        _iconLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _iconLabel.backgroundColor = [UIColor clearColor];
        // 比数字小一点
        _iconLabel.font = KBFont(FontSize - 5);
        _iconLabel.textColor = TitleColor;
        _iconLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_iconLabel];
    }
    return _iconLabel;
}

// logo
- (UIImageView *)iconFlag
{
    if (!_iconFlag) {
        UIImage *image = [UIImage imageNamed:self.icon];
        _iconFlag = [[UIImageView alloc] initWithImage:image];
        _iconFlag.contentMode = UIViewContentModeScaleAspectFit;
        // logo圆角
        _iconFlag.layer.cornerRadius = ICONHEIGHT * 0.5;
        _iconFlag.layer.masksToBounds = true;
        [_iconFlag sizeToFit];
        [self addSubview:_iconFlag];
    }
    return _iconFlag;
}

//hide

- (UIButton *)hideBtn
{
    if (!_hideBtn) {
        _hideBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_hideBtn setTitle:@"⬇︎" forState:UIControlStateNormal];
        [_hideBtn.titleLabel setFont:[UIFont systemFontOfSize:24]];
        [_hideBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [self addSubview:_hideBtn];
        [_hideBtn addTarget:self action:@selector(hideAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _hideBtn;
}

- (void)hideAction:(UIButton *)btn
{
    UITextField *tmp = (UITextField *)self.inputSource;
    [tmp resignFirstResponder];
}

- (void)setIcon:(NSString *)icon
{
    _icon = [icon copy];
    UIImage *image = [UIImage imageNamed:self.icon];
    self.iconFlag.image = image;
}

// 计算logo title的位置
- (void)setEnterprise:(NSString *)enterprise
{
    if (enterprise.length > 0) {
        _enterprise = [enterprise copy];
        // logo 其实这就是宽高
        CGFloat icon_w_h = ICONHEIGHT;
        // title w
        CGFloat width = [self widthForInfo:enterprise];
        // logow 宽高+0.5宽高+宽度
        CGFloat wwww = icon_w_h * 1.5 + width;
        // 一半 居中
        CGFloat start_x = (NHSCREEN_WIDTH - wwww) * 0.5 + icon_w_h * 1.5;
        // y轴 上0.25 logo0.5 线间隔还剩0.25
        CGRect bounds = CGRectMake(start_x, TITLEHEIGHT * 0.25, width, TITLEHEIGHT * 0.5);
        self.iconLabel.frame = bounds;
        self.iconLabel.text = enterprise;
        // logo的frame 间距是0.5的宽高
        bounds.origin.x -= icon_w_h * 1.5;
        bounds.size = CGSizeMake(icon_w_h, icon_w_h);
        self.iconFlag.frame = bounds;
        
        bounds = CGRectMake(NHSCREEN_WIDTH - 40, 0, 40, 40);
        self.hideBtn.frame = bounds;
    }
}

// 字符串的宽度
- (CGFloat)widthForInfo:(NSString *)info
{
    if (info.length == 0) {
        return 0;
    }
    NSDictionary *attributs = [NSDictionary dictionaryWithObjectsAndKeys:KBFont(FontSize - 5), NSFontAttributeName, nil];
    return [info sizeWithAttributes:attributs].width;
}

@end