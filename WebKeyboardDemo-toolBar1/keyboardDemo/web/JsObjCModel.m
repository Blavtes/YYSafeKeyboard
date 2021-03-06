//
//  JsObjCModel.m
//  WebViewJavascript
//
//  Created by Blavtes on 16/3/18.
//  Copyright © 2016年 Blavtes. All rights reserved.
//

#import "JsObjCModel.h"

@implementation JsObjCModel


- (void)callKeyboard:(NSString *)textId Type:(NSString *)type
{
    self.textId = textId;
    if ([type isEqualToString:@"abc"])
    {
        self.input = [SafeKBInputView shareKBInputViewWithTypeABC];
    }
    else if ([type isEqualToString:@"num"])
    {
        self.input = [SafeKBInputView shareKBInputViewWithTypeNum];
    }
    else if ([type isEqualToString:@"all"])
    {
        self.input = [SafeKBInputView shareKBInputViewWithTypeAll];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        // 更UI
        [self.input show];
    });
    self.input.InputViewDelegate = self;

}


#pragma mark - SafeKBInputViewDelegate
- (void)safeKBInputViewDidChangeText:(SafeKBInputView *)inputView
{
    NSString *encodeStr = [inputView.trueText stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLPasswordAllowedCharacterSet]];
    
    NSString *js = [NSString stringWithFormat:@"var field = document.getElementById('%@'); field.value= '%@'; var btn = document.getElementById('button'); var te = \"%@\"; te = decodeURIComponent(te); btn.value= te; ",self.textId,inputView.placeholderText,encodeStr ];
    [self.webView stringByEvaluatingJavaScriptFromString:js];
    NSLog(@"%@",inputView.trueText);
}

@end
