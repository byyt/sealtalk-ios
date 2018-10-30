//
//  RCDRegisterViewController.h
//  YunChuang
//
//  Created by Liv on 15/3/10.
//  Copyright (c) 2015年 RongCloud. All rights reserved.
//

#import "RCAnimatedImagesView.h"
#import <UIKit/UIKit.h>
@interface RCDRegisterViewController_New : UIViewController

//下面的值是通过验证码登录或者忘记密码界面先传进来的
@property(nonatomic, strong) NSString *phoneString;
@property(nonatomic, strong) NSString *codeToken;
@property(nonatomic, strong) NSString *loginType;

@end

