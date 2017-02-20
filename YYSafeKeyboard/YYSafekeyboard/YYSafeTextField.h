//
// YYSafeTextField.h
//  YYSafeKeyboard
//
//  Created by Blavtes on 16/4/7.
//  Copyright © 2017年 Blavtes. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YYSafeKeyboard.h"
@class YYSafeTextField;

@protocol YYSafeTextFieldDelegate <NSObject>
// 点击完成 键盘消失
-(void)safeTextFieldDidResignFirstResponder:(YYSafeTextField *)textField;
// 删除字符 inputView需要知道，并传递给web
-(void)safeTextFieldDidDeleteString:(YYSafeTextField *)textField;

@end

@interface YYSafeTextField : UITextField

@property (nonatomic, assign) YYSafeKeyboardType KBType;
@property (nonatomic, weak) id <YYSafeTextFieldDelegate> safeTextDelegate;

- (instancetype)initWithkeyboardType:(YYSafeKeyboardType)type;
@end
