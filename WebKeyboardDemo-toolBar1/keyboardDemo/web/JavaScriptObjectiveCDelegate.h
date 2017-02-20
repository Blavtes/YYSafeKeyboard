//
//  JavaScriptObjectiveCDelegate.h
//  WebViewJavascript
//
//  Created by Blavtes on 16/3/18.
//  Copyright © 2016年 Blavtes. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <JavaScriptCore/JavaScriptCore.h>

@protocol JavaScriptObjectiveCDelegate <JSExport>

- (void)callKeyboard:(NSString *)textId Type:(NSString *)type;

@end
