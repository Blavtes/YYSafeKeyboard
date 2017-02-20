//
//  JsObjCModel.h
//  WebViewJavascript
//
//  Created by Blavtes on 16/3/18.
//  Copyright © 2016年 Blavtes. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "JavaScriptObjectiveCDelegate.h"
#import "SafeKBInputView.h"
#import "ViewController.h"

@interface JsObjCModel : NSObject<JavaScriptObjectiveCDelegate,SafeKBInputViewDelegate>
@property (nonatomic, weak) JSContext *jsContext;
@property (nonatomic, weak) UIWebView *webView;

@property (nonatomic, strong) SafeKBInputView *input;
@property (nonatomic, weak) ViewController *webEngine;

@property (nonatomic, strong) NSString *textId;
@end
