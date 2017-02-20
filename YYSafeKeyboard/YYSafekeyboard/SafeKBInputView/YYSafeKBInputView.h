//
//  YYSafeKBInputView.h
//  YYSafeKeyboard
//
//  Created by Blavtes on 17/1/1.
//  Copyright © 2017年 Blavtes. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YYSafeTextField.h"
@class YYSafeKBInputView;

// 点击的代理事件 传递到外层
@protocol YYSafeKBInputViewDelegate <NSObject>
// 每次输入的代理事件
-(void)safeKBInputView:(YYSafeKBInputView *)inputView didChangeText:(NSString *)text placeholderText:(NSString *)placeholder textField:(YYSafeTextField *)textField;


@end

@interface YYSafeKBInputView : UIView <YYSafeTextFieldDelegate, UITextFieldDelegate>

@property (nonatomic, strong) YYSafeTextField *textField;
@property (nonatomic, copy) NSMutableString *placeholderText;
@property (nonatomic, copy) NSString *trueText;
@property (nonatomic, assign) CGFloat keyboardHeght;

@property (nonatomic, weak) id <YYSafeKBInputViewDelegate> InputViewDelegate;

+(YYSafeKBInputView *)shareKBInputViewWithTypeNum;
+(YYSafeKBInputView *)shareKBInputViewWithTypeNumDecimal;
+(YYSafeKBInputView *)shareKBInputViewWithTypeABC;

- (instancetype)initWithYYSafeKeyboardType:(YYSafeKeyboardType)type;
// 显示
-(void)show;

@end
