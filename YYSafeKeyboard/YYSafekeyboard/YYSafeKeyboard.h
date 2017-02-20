//
//  YYSafeKeyboard.h
//  YYSafeKeyboard
//
//  Created by Blavtes on 17/1/2.
//  Copyright © 2017年 Blavtes. All rights reserved.
//

#import <UIKit/UIKit.h>
// 键盘高度
#define KEYBOARDHEIGHT 216

enum {
    YYKBImageLeft = 0,
    YYKBImageInner,
    YYKBImageRight,
    YYKBImageMax
};

typedef NS_ENUM(NSInteger,YYSafeKeyboardType){
    YYSafeKeyboardTypeNum         = 1 << 0,
    YYSafeKeyboardTypeNumDecimal  = 1 << 1,
    YYSafeKeyboardTypeABC         = 1 << 2
};

typedef enum : NSUInteger {
    kShiftLowerType = 1, // 小写
    kShiftUpperType, //大
    kShiftDoubelType,// 双击
} kShiftType;


@interface YYSafeKeyboard : UIView

/**
 *  logo
 */
@property (nonatomic,copy) NSString *icon;

/**
 *  title
 */
@property (nonatomic,copy) NSString *enterprise;

/*!
 *  @brief such as UITextField,UITextView,UISearchBar
 */
@property (nonatomic,strong) UIView *inputSource;

+ (instancetype)keyboardWithType:(YYSafeKeyboardType)type;

// 设置键盘文字
- (void)setRandomNumberText;

//+ (YYSafeKeyboard *)shareKeyboardViewWithType:(KeyboardType)type;
@end
