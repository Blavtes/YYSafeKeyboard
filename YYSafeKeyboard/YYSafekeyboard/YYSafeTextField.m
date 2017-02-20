//
// YYSafeTextField.m
//  YYSafeKeyboard
//
//  Created by Blavtes on 16/4/7.
//  Copyright © 2017年 Blavtes. All rights reserved.
//

#import "YYSafeTextField.h"

@implementation YYSafeTextField

- (instancetype)init
{
    if (self = [super init]) {
        self.KBType = YYSafeKeyboardTypeABC;
    }
    return self;
}

- (instancetype)initWithkeyboardType:(YYSafeKeyboardType)type
{
    self = [super init];
    if (self) {
        self.KBType = type;
    }
    return self;
}
// 成为第一响应者
- (BOOL)becomeFirstResponder
{
    BOOL bflag = [super becomeFirstResponder];
    if(bflag)
    {
        YYSafeKeyboard *kb = (YYSafeKeyboard *)self.inputView;
        kb.inputSource = self;
        [kb setRandomNumberText];
    }
    return bflag;
}

- (BOOL)resignFirstResponder
{
    YYSafeKeyboard *kb = (YYSafeKeyboard *)self.inputView;
    kb.inputSource = nil;
    BOOL ret = [super resignFirstResponder];
    if (self.safeTextDelegate && [self.safeTextDelegate respondsToSelector:@selector(safeTextFieldDidResignFirstResponder:)])
    {
        [self.safeTextDelegate safeTextFieldDidResignFirstResponder:self];
    }
    return ret;
}

-(void)deleteBackward
{
    [super deleteBackward];
    if (self.safeTextDelegate && [self.safeTextDelegate respondsToSelector:@selector(safeTextFieldDidDeleteString:)])
    {
        [self.safeTextDelegate safeTextFieldDidDeleteString:self];
    }
}

#pragma mark - setter
-(void)setKBType:(YYSafeKeyboardType)KBType
{
    _KBType = KBType;
    YYSafeKeyboard *keyboard = [YYSafeKeyboard keyboardWithType:KBType];
    self.inputView = keyboard;
    keyboard.inputSource = self;
}

@end
