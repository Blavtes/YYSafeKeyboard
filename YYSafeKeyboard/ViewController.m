//
//  ViewController.m
//  YYSafeKeyboard
//
//  Created by Blavtes on 17/1/2.
//  Copyright © 2017年 Blavtes. All rights reserved.
//

#import "ViewController.h"
#import "YYSafeTextField.h"
#import "YYSafeKBInputView.h"

@interface ViewController () <YYSafeKBInputViewDelegate>
/**
 *  占位符
 */
@property (weak, nonatomic) IBOutlet UILabel *lblWebpwd;
@property (weak, nonatomic) IBOutlet UILabel *lblWebnum;
@property (weak, nonatomic) IBOutlet UILabel *lblWebnumDecimal;
/**
 *  真实内容
 */
@property (weak, nonatomic) IBOutlet UILabel *lblWebpwdTrue;
@property (weak, nonatomic) IBOutlet UILabel *lblWebnumTrue;
@property (weak, nonatomic) IBOutlet UILabel *lblWebnumDecimalTrue;


@property (nonatomic, strong) YYSafeKBInputView *input;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    YYSafeTextField *te = [[YYSafeTextField alloc] initWithkeyboardType:YYSafeKeyboardTypeABC];
    te.frame = CGRectMake(200, 100, 100, 50);
    te.font = [UIFont systemFontOfSize:33];
    te.backgroundColor = [UIColor redColor];
    te.secureTextEntry = YES;
    [self.view addSubview:te];
    [self.view endEditing:YES];
}

- (IBAction)showABC:(id)sender
{
    self.input = [YYSafeKBInputView shareKBInputViewWithTypeABC];
    self.input.InputViewDelegate = self;
    [self.input show];
}

- (IBAction)showNum:(id)sender
{
    self.input = [YYSafeKBInputView shareKBInputViewWithTypeNum];
    self.input.InputViewDelegate = self;
    [self.input show];
}

- (IBAction)showNumDecimal:(id)sender
{
    self.input = [YYSafeKBInputView shareKBInputViewWithTypeNumDecimal];
    self.input.InputViewDelegate = self;
    [self.input show];
}

#pragma mark - delegate

- (void)safeKBInputView:(YYSafeKBInputView *)inputView didChangeText:(NSString *)text placeholderText:(NSString *)placeholder textField:(YYSafeTextField *)textField
{
    switch (textField.KBType)
    {
        case YYSafeKeyboardTypeABC:
        {
            self.lblWebpwd.text = placeholder;
            self.lblWebpwdTrue.text = text;
        
        }
            break;
        case YYSafeKeyboardTypeNum:
        {
            self.lblWebnum.text = placeholder;
            self.lblWebnumTrue.text = text;
        }
            break;
        case YYSafeKeyboardTypeNumDecimal:
        {
            self.lblWebnumDecimal.text = placeholder;
            self.lblWebnumDecimalTrue.text = text;
        }
            break;
            
        default:
            break;
    }
}
@end
