//
//  YYSafeKBInputView.m
//  YYSafeKeyboard
//
//  Created by Blavtes on 17/1/1.
//  Copyright © 2017年 Blavtes. All rights reserved.
//

#import "YYSafeKBInputView.h"

static YYSafeKBInputView *keyboardViewTypeNumInstance = nil;
static YYSafeKBInputView *keyboardViewTypeNumDecimalInstance = nil;
static YYSafeKBInputView *keyboardViewTypeABCInstance = nil;
@implementation YYSafeKBInputView

+(YYSafeKBInputView *)shareKBInputViewWithTypeNum
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{

        keyboardViewTypeNumInstance = [[YYSafeKBInputView alloc] initWithYYSafeKeyboardType:YYSafeKeyboardTypeNum];
    });
    return keyboardViewTypeNumInstance;
}

+(YYSafeKBInputView *)shareKBInputViewWithTypeNumDecimal
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        keyboardViewTypeNumDecimalInstance = [[YYSafeKBInputView alloc] initWithYYSafeKeyboardType:YYSafeKeyboardTypeNumDecimal];
    });
    return keyboardViewTypeNumDecimalInstance;
}

+(YYSafeKBInputView *)shareKBInputViewWithTypeABC
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        keyboardViewTypeABCInstance = [[YYSafeKBInputView alloc] initWithYYSafeKeyboardType:YYSafeKeyboardTypeABC];
    });
    return keyboardViewTypeABCInstance;
}

- (instancetype)initWithYYSafeKeyboardType:(YYSafeKeyboardType)type
{
    self = [super init];
    if (self) {
        self.textField = [[YYSafeTextField alloc] init];
        self.textField.KBType = type;
        self.textField.delegate = self;
        self.textField.safeTextDelegate = self;
        self.trueText = @"";
        self.keyboardHeght = KEYBOARDHEIGHT;
        [self addSubview:self.textField];
    }
    return self;
}

- (void)show
{
    UIViewController *topVC = [self getCurrentVC];
    [topVC.view addSubview:self];
    [self.textField becomeFirstResponder];
    self.textField.text = @"";
    self.trueText = @"";
    self.placeholderText = [NSMutableString string];
}

#pragma mark - delegate

// textfield 取消第一响应者 ，view消失
- (void)safeTextFieldDidResignFirstResponder:(YYSafeTextField *)textField
{
    [self removeFromSuperview];
}

// 删除
- (void)safeTextFieldDidDeleteString:(YYSafeTextField *)textField
{
    _placeholderText  = [NSMutableString string];
    NSInteger len = textField.text.length;
    for (int i = 0; i < len; i++)
    {
        [self.placeholderText appendString:@"●"];
    }
    self.trueText = textField.text;
    
    if (self.InputViewDelegate && [self.InputViewDelegate respondsToSelector:@selector(safeKBInputView:didChangeText:placeholderText:textField:)]) {
        [self.InputViewDelegate safeKBInputView:self didChangeText:self.trueText placeholderText:self.placeholderText textField:self.textField];
    }
}

// 增加
-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    _placeholderText  = [NSMutableString string];
    NSInteger len = textField.text.length + 1;
    for (int i = 0; i < len; i++)
    {
        [self.placeholderText appendString:@"●"];
    }
    self.trueText = [self.trueText stringByAppendingString:string];
    
    
    if (self.InputViewDelegate && [self.InputViewDelegate respondsToSelector:@selector(safeKBInputView:didChangeText:placeholderText:textField:)])
    {
        [self.InputViewDelegate safeKBInputView:self didChangeText:self.trueText placeholderText:self.placeholderText textField:self.textField];
    }
    return YES;
}

#pragma mark - getter setter

//获取当前屏幕显示的viewcontroller
- (UIViewController *)getCurrentVC
{
    UIViewController *result = nil;
    
    UIWindow * window = [[UIApplication sharedApplication] keyWindow];
    if (window.windowLevel != UIWindowLevelNormal)
    {
        NSArray *windows = [[UIApplication sharedApplication] windows];
        for(UIWindow * tmpWin in windows)
        {
            if (tmpWin.windowLevel == UIWindowLevelNormal)
            {
                window = tmpWin;
                break;
            }
        }
    }
    
    UIView *frontView = [[window subviews] objectAtIndex:0];
    id nextResponder = [frontView nextResponder];
    
    if ([nextResponder isKindOfClass:[UIViewController class]])
        result = nextResponder;
    else
        result = window.rootViewController;
    
    return result;
}


@end
