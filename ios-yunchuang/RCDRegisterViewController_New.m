//
//  RCDRegisterViewController.m
//  RCloudMessage
//
//  Created by Liv on 15/3/10.
//  Copyright (c) 2015年 RongCloud. All rights reserved.
//

#import "RCDRegisterViewController_New.h"
#import "AFHttpTool.h"
#import "MBProgressHUD.h"
#import "RCDCommonDefine.h"
#import "RCDHttpTool.h"
#import "RCDUtilities.h"
#import "RCDataBaseManager.h"
#import "RCDMainTabBarViewController.h"
#import "RCDNavigationViewController.h"
#import "RCDLoginViewController.h"
#import "RCDTextFieldValidate.h"
#import "RCUnderlineTextField.h"
#import "UIColor+RCColor.h"
#import <RongIMLib/RongIMLib.h>
#import "RCDRCIMDataSource.h"
#import "ToastUtil.h"

@interface RCDRegisterViewController_New () <UITextFieldDelegate, RCIMConnectionStatusDelegate>
@property(nonatomic, strong) UIView *phoneBg;
@property(nonatomic, strong) UILabel *topLabel;
@property(nonatomic, strong) UIImageView *portraitImageView;
@property(nonatomic, strong) IBOutlet UITextField *nickNameTextField;
@property(nonatomic, strong) UIView *sexBg;
@property(nonatomic, strong) UIImageView *manImageView;
@property(nonatomic, strong) UIImageView *womanImageView;
@property(nonatomic, strong) IBOutlet UIButton *sureButton;

@property(nonatomic, strong) NSString *nickName;
@property(nonatomic, strong) NSString *password;

@property(nonatomic, strong) NSString *loginUserName;
@property(nonatomic, strong) NSString *loginUserId;
@property(nonatomic, strong) NSString *loginToken;

@property(nonatomic) int loginFailureTimes;//登录失败次数
@property(nonatomic, strong) NSTimer *retryTime;

@end

@implementation RCDRegisterViewController_New {
    //这里声明的是私有变量？
    
}
#define NickNameFieldTag 1001
MBProgressHUD *hud; //这里声明的是私有变量？

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    
    _loginFailureTimes = 0;

    //设置背景
    _phoneBg = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
    _phoneBg.backgroundColor = [UIColor colorWithHexString:@"FFFFFF" alpha:1.0];
    [self.view addSubview:_phoneBg];
    
    //顶部文字
    [self topLabelLayout];
    
    //头像布局
    [self portraitLayout];
    
    //昵称布局
    [self nickNameLayout];
    
    //昵称布局
    [self sexLayout];
    
    //昵称布局
    [self sureLayout];
    
    //整体界面的约束
    [self constraintAllView];
    
    //键盘弹起，将界面往上移
    [self otherInit];
    
    if ([_loginType isEqual:@"code_login"]) {
        //如果是验证码登录，随机生成一串16位密码（确保不被盗密码）
        _password = [self getRandomString:16];
//        _password = @"123456";
        [_sureButton setTitle:@"确认" forState:UIControlStateNormal];
    } else if ([_loginType isEqual:@"forget_password"]) {
        //忘记密码，完善资料后进入设置密码界面
        _password = @"";
        [_sureButton setTitle:@"下一步" forState:UIControlStateNormal];
    }else{
        _password = @"qw0rqrq12r4ew2";
        [_sureButton setTitle:@"确认" forState:UIControlStateNormal];
    }
    
    NSLog(@"xxxxxx  %@", _phoneString);
    NSLog(@"xxxxxx  %@", _codeToken);
    NSLog(@"xxxxxx  %@", _loginType);
    NSLog(@"xxxxxx  %@", _password);
}

//顶部文字布局
- (void)topLabelLayout {
    _topLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _topLabel.textAlignment = NSTextAlignmentCenter;
    _topLabel.text = @"请先完善个人资料哦～";
    [_topLabel setFont:[UIFont systemFontOfSize:25.f]];
    [_topLabel setTextColor:[UIColor colorWithHexString:@"030303" alpha:1.0]];
    _topLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:_topLabel];
}

//头像布局
- (void)portraitLayout {
    //加号
    UIImage *portraitImage = [UIImage imageNamed:@"register_code_portrait"];
    _portraitImageView = [[UIImageView alloc] initWithImage:portraitImage];
    _portraitImageView.contentMode = UIViewContentModeScaleAspectFit;
    _portraitImageView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:_portraitImageView];
}

//昵称布局
- (void)nickNameLayout {
    //验证码或密码输入区域
    _nickNameTextField = [[RCUnderlineTextField alloc] initWithFrame:CGRectZero];
    _nickNameTextField.backgroundColor = [UIColor clearColor];
    _nickNameTextField.tag = NickNameFieldTag;
    _nickNameTextField.delegate = self;
    UIColor *color = [UIColor colorWithHexString:@"C5BABA" alpha:1.0];
    _nickNameTextField.attributedPlaceholder =
    [[NSAttributedString alloc] initWithString:@"起一个响亮的名字吧" attributes:@{NSForegroundColorAttributeName : color}];
    _nickNameTextField.textColor = [UIColor colorWithHexString:@"000000" alpha:1.0];
    _nickNameTextField.textAlignment = NSTextAlignmentCenter;
    _nickNameTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    _nickNameTextField.font = [UIFont fontWithName:@"Heiti SC" size:15.0];
    _nickNameTextField.keyboardType = UIKeyboardTypeDefault;
    _nickNameTextField.translatesAutoresizingMaskIntoConstraints = NO;
    //添加监听，使输入昵称字符个数不超过20个
    [_nickNameTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    [self.view addSubview:_nickNameTextField];
}

//昵称布局
- (void)sexLayout {
    //一整行
    _sexBg = [[UIView alloc] initWithFrame:CGRectZero];
    _sexBg.translatesAutoresizingMaskIntoConstraints = NO;
    _sexBg.userInteractionEnabled = YES;
    [self.view addSubview:_sexBg];
    //男图标
    UIImage *manImage = [UIImage imageNamed:@"register_woman"];
    _manImageView = [[UIImageView alloc] initWithImage:manImage];
    _manImageView.contentMode = UIViewContentModeScaleAspectFit;
    _manImageView.translatesAutoresizingMaskIntoConstraints = NO;
    [_sexBg addSubview:_manImageView];
    //女图标
    UIImage *woManImage = [UIImage imageNamed:@"register_woman"];
    _womanImageView = [[UIImageView alloc] initWithImage:woManImage];
    _womanImageView.contentMode = UIViewContentModeScaleAspectFit;
    _womanImageView.translatesAutoresizingMaskIntoConstraints = NO;
    [_sexBg addSubview:_womanImageView];
    //约束
    NSDictionary *views =
    NSDictionaryOfVariableBindings(_manImageView, _womanImageView);
    NSArray *manImageView_V = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_manImageView]|" options:0 metrics:nil views:views];
    NSArray *womanImageView_V = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_womanImageView]|" options:0 metrics:nil views:views];
    NSArray *all_H = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_manImageView]-70-[_womanImageView]|" options:0 metrics:nil views:views];
    [_sexBg addConstraints:manImageView_V];
    [_sexBg addConstraints:womanImageView_V];
    [_sexBg addConstraints:all_H];
}

- (void)sureLayout {
    _sureButton = [[UIButton alloc] init];
    [_sureButton setBackgroundColor:[UIColor colorWithHexString:@"EFF059" alpha:1.0]];
    [_sureButton setTitle:@"确定" forState:UIControlStateNormal];
    [_sureButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_sureButton addTarget:self action:@selector(actionSure:) forControlEvents:UIControlEventTouchUpInside];
    _sureButton.translatesAutoresizingMaskIntoConstraints = NO;
    [_sureButton.titleLabel setFont:[UIFont fontWithName:@"Heiti SC" size:18.0]];
    _sureButton.layer.masksToBounds = YES;
    _sureButton.layer.cornerRadius = 6.f;
    
    [self.view addSubview:_sureButton];
}

//整体界面的约束
- (void)constraintAllView {
    //居中约束
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_topLabel
                                                          attribute:NSLayoutAttributeCenterX
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeCenterX
                                                         multiplier:1.0
                                                           constant:0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_portraitImageView
                                                          attribute:NSLayoutAttributeCenterX
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeCenterX
                                                         multiplier:1.0
                                                           constant:0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_nickNameTextField
                                                          attribute:NSLayoutAttributeCenterX
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeCenterX
                                                         multiplier:1.0
                                                           constant:0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_sexBg
                                                          attribute:NSLayoutAttributeCenterX
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeCenterX
                                                         multiplier:1.0
                                                           constant:0]];
    
    NSDictionary *views =
    NSDictionaryOfVariableBindings(_topLabel,_portraitImageView,_nickNameTextField,_sexBg,
                                   _sureButton);
    
    NSArray *sureButton_H= [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-55-[_sureButton]-55-|" options:0 metrics:nil views:views];
    
    NSArray *all_V= [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-160-[_topLabel]-30-[_portraitImageView]-50-[_nickNameTextField(30)]-40-[_sexBg(30)]-45-[_sureButton(40)]" options:0 metrics:nil views:views];
    
    [self.view addConstraints:sureButton_H];
    [self.view addConstraints:all_V];
}

//点击空白处收起键盘
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

//点击键盘中的return收起键盘
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    NSLog(@"textFieldShouldReturn");
    [textField resignFirstResponder];
    return YES;
}

//监听UITextField内容的变化
- (void)textFieldDidChange:(UITextField *)textField {
    
}

//关于内存释放的处理
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//1、这个类被release的时候会被调用；
//2、这个对象的retain count为0的时候会被调用；或者说一个对象或者类被置为nil的时候；
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
}

//其他初始化设置
- (void)otherInit {
    //监听键盘的起落
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:self.view.window];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:self.view.window];
}

//键盘升起时动画
- (void)keyboardWillShow:(NSNotification *)notif {
    
    CATransition *animation = [CATransition animation];
    animation.type = kCATransitionFade;
    animation.duration = 0.25;
    [_topLabel.layer addAnimation:animation forKey:nil];
    _topLabel.hidden = YES;
    
    [UIView animateWithDuration:0.25
                     animations:^{
                         
                         self.view.frame =
                         CGRectMake(0.f, -150, self.view.frame.size.width, self.view.frame.size.height);
                     }
                     completion:nil];
}

//键盘关闭时动画
- (void)keyboardWillHide:(NSNotification *)notif {
    CATransition *animation = [CATransition animation];
    animation.type = kCATransitionFade;
    animation.duration = 0.25;
    [_topLabel.layer addAnimation:animation forKey:nil];
    _topLabel.hidden = NO;
    
    [UIView animateWithDuration:0.25
                     animations:^{
                         self.view.frame =
                         CGRectMake(0.f, 0.f, self.view.frame.size.width, self.view.frame.size.height);
                     }
                     completion:nil];
}


//点击登录
- (IBAction)actionSure:(id)sender {
    
    if (self.retryTime) {
        [self invalidateRetryTime];
    }
    
    self.retryTime = [NSTimer scheduledTimerWithTimeInterval:60
                                                      target:self
                                                    selector:@selector(retryConnectionFailed)
                                                    userInfo:nil
                                                     repeats:NO];
    //网络情况
    RCNetworkStatus status = [[RCIMClient sharedRCIMClient] getCurrentNetworkStatus];
    if (RC_NotReachable == status) {
        [ToastUtil showMessage:@"网络未连接" duration:2.0];
        return;
    }
    
    //判断资料填写的合法性
    if(![self checkDataLegal]){
        return;
    }
    
    hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.color = [UIColor colorWithHexString:@"343637" alpha:0.8];
    hud.labelText = @"登录中...";
    [hud show:YES];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"UserCookies"];
    
    if ([_loginType isEqual:@"code_login"]) {
        //验证码登录，完善资料后直接登录
        [self requestCodeRegister];
    } else if ([_loginType isEqual:@"forget_password"]) {
        //忘记密码，完善资料后进入设置密码界面
        NSLog(@"forget_password");
    }
    
}

//获取指定长度的随机字符串
-(NSString *)getRandomString:(NSInteger)len {
    NSString *letters = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    NSMutableString *randomString = [NSMutableString stringWithCapacity: len];
    
    for (NSInteger i = 0; i < len; i++) {
        [randomString appendFormat: @"%C", [letters characterAtIndex: arc4random_uniform([letters length])]];
    }
    return randomString;
}

//检查昵称、头像、性别等填写合法性
- (BOOL)checkDataLegal {
    //获取昵称
    _nickName = [(UITextField *)[self.view viewWithTag:NickNameFieldTag] text];
    
    if (_nickName.length == 0) {
        [ToastUtil showMessage:@"昵称不能为空" duration:2.0];
        return NO;
    }
    if (_nickName.length > 32) {
        [ToastUtil showMessage:@"昵称不能大于32位" duration:2.0];
        return NO;
    }
    NSRange _range = [_nickName rangeOfString:@" "];
    if (_range.location != NSNotFound) {
        [ToastUtil showMessage:@"昵称中不能有空格" duration:2.0];
        return NO;
    }
    return YES;
}

//验证码注册
- (void)requestCodeRegister {
    [AFHttpTool codeRegisterWithNickName:_nickName password:_password verficationToken:_codeToken
        success:^(id response) {
            NSDictionary *results = response;
            NSString *code = [NSString stringWithFormat:@"%@", [results objectForKey:@"code"]];
            if (code.intValue == 200) {
                //验证码的verificationToken验证成功后，开始进行验证码登录
                [self codeLoginRequest:_codeToken];
            }else {
                [hud hide:YES];
                [ToastUtil showMessage:@"登录失败，请稍后重试" duration:2.0];
            }
            
        }failure:^(NSError *err) {
        
        }];
}

//验证码的verificationToken验证成功后，开始进行验证码登录
-(void)codeLoginRequest:(NSString * )verificationToken {
    //验证码登录
    [AFHttpTool
     codeLoginWithRegion:@"86" phoneNumber:_phoneString verficationToken:verificationToken
     success:^(id response) {
         NSDictionary *results = response;
         NSString *code = [NSString stringWithFormat:@"%@", [results objectForKey:@"code"]];
         if (code.intValue == 200) {
             NSDictionary *result = [results objectForKey:@"result"];
             NSString *token = [result objectForKey:@"token"];
             NSString *userId = [result objectForKey:@"id"];
             //验证码的verificationToken验证成功后，用返回来的token连接融云服务器
             [self loginRongCloud:_phoneString userId:userId token:token];
         }else {
             [hud hide:YES];
             [ToastUtil showMessage:@"登录失败，请稍后重试" duration:2.0];
         }
     }
     failure:^(NSError *err) {
         [hud hide:YES];
         [ToastUtil showMessage:@"登录失败，请稍后重试" duration:2.0];
     }];
}


/**
 *  登录融云服务器
 *
 *  @param userName 用户名
 *  @param token    token
 */
- (void)loginRongCloud:(NSString *)userName
                userId:(NSString *)userId
                 token:(NSString *)token {
    self.loginUserName = userName;
    self.loginUserId = userId;
    self.loginToken = token;
    
    //登录融云服务器
    [[RCIM sharedRCIM]
     connectWithToken:token
     success:^(NSString *userId) {
         //登录成功
         NSLog([NSString stringWithFormat:@"token is %@  userId is %@", token, userId], nil);
         self.loginUserId = userId;
         //登录成功后，保存用户信息，以及同步用户信息
         [self loginSuccess:self.loginUserName
                     userId:self.loginUserId
                      token:self.loginToken];
     }
     error:^(RCConnectErrorCode status) {
         //登录失败，下面是切回主线程刷新ui，弹出失败信息
         dispatch_async(dispatch_get_main_queue(), ^{
             //关闭HUD
             [hud hide:YES];
             NSLog(@"RCConnectErrorCode is %ld", (long)status);
             
             
             // SDK会自动重连登录，这时候需要监听连接状态
             [[RCIM sharedRCIM] setConnectionStatusDelegate:self];
         });
         //        //SDK会自动重连登陆，这时候需要监听连接状态
         //        [[RCIM sharedRCIM] setConnectionStatusDelegate:self];
     }
     tokenIncorrect:^{
         //token不正确，会进行一次重新获取token的过程
         NSLog(@"IncorrectToken");
         
         if (_loginFailureTimes < 1) {
             _loginFailureTimes++;
             //获取token的请求
             [AFHttpTool
              getTokenSuccess:^(id response) {
                  //获取token成功
                  NSString *token = response[@"result"][@"token"];
                  NSString *userId = response[@"result"][@"userId"];
                  //重新用token登录融云服务器
                  [self loginRongCloud:userName userId:userId token:token];
              }
              failure:^(NSError *err) {
                  //获取token失败，切回主线程，弹出失败信息，刷新ui
                  dispatch_async(dispatch_get_main_queue(), ^{
                      [hud hide:YES];
                      NSLog(@"Token无效");
                      [ToastUtil showMessage:@"无法连接到服务器！" duration:2.0];
                  });
              }];
         }
     }];
}

- (void)onRCIMConnectionStatusChanged:(RCConnectionStatus)status {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (status == ConnectionStatus_Connected) {
            [RCIM sharedRCIM].connectionStatusDelegate =
            (id<RCIMConnectionStatusDelegate>)[UIApplication sharedApplication].delegate;
            [self loginSuccess:self.loginUserName
                        userId:self.loginUserId
                         token:self.loginToken];
        } else if (status == ConnectionStatus_NETWORK_UNAVAILABLE) {
            [ToastUtil showMessage:@"当前网络不可用，请检查" duration:2.0];
        } else if (status == ConnectionStatus_KICKED_OFFLINE_BY_OTHER_CLIENT) {
            [ToastUtil showMessage:@"您的帐号在别的设备上登录，您被迫下线！" duration:2.0];
        } else if (status == ConnectionStatus_TOKEN_INCORRECT) {
            NSLog(@"Token无效");
            [ToastUtil showMessage:@"无法连接到服务器！" duration:2.0];
            if (self.loginFailureTimes < 1) {
                self.loginFailureTimes++;
                [AFHttpTool
                 getTokenSuccess:^(id response) {
                     self.loginToken = response[@"result"][@"token"];
                     self.loginUserId = response[@"result"][@"userId"];
                     [self loginRongCloud:self.loginUserName
                                   userId:self.loginUserId
                                    token:self.loginToken];
                 }
                 failure:^(NSError *err) {
                     dispatch_async(dispatch_get_main_queue(), ^{
                         [hud hide:YES];
                         NSLog(@"Token无效");
                         [ToastUtil showMessage:@"无法连接到服务器！" duration:2.0];
                     });
                 }];
            }
        } else {
            NSLog(@"RCConnectErrorCode is %zd", status);
        }
    });
}

//登录成功后，保存用户信息，以及同步用户信息
- (void)loginSuccess:(NSString *)userName
              userId:(NSString *)userId
               token:(NSString *)token {
    [self invalidateRetryTime];
    //保存默认用户
    [DEFAULTS setObject:userName forKey:@"userName"];
    [DEFAULTS setObject:token forKey:@"userToken"];
    [DEFAULTS setObject:userId forKey:@"userId"];
    [DEFAULTS synchronize];
    //保存“发现”的信息
    [RCDHTTPTOOL getSquareInfoCompletion:^(NSMutableArray *result) {
        [DEFAULTS setObject:result forKey:@"SquareInfoList"];
        [DEFAULTS synchronize];
    }];
    
    //同步用户信息
    [AFHttpTool
     getUserInfo:userId
     success:^(id response) {
         if ([response[@"code"] intValue] == 200) {
             NSDictionary *result = response[@"result"];
             NSString *nickname = result[@"nickname"];
             NSString *portraitUri = result[@"portraitUri"];
             RCUserInfo *user =
             [[RCUserInfo alloc] initWithUserId:userId name:nickname portrait:portraitUri];
             if (!user.portraitUri || user.portraitUri.length <= 0) {
                 user.portraitUri = [RCDUtilities defaultUserPortrait:user];
             }
             [[RCDataBaseManager shareInstance] insertUserToDB:user];
             [[RCIM sharedRCIM] refreshUserInfoCache:user withUserId:userId];
             [RCIM sharedRCIM].currentUserInfo = user;
             [DEFAULTS setObject:user.portraitUri forKey:@"userPortraitUri"];
             [DEFAULTS setObject:user.name forKey:@"userNickName"];
             [DEFAULTS synchronize];
         }
     }
     failure:^(NSError *err){
         
     }];
    //同步群组
    [RCDDataSource syncGroups];
    [RCDDataSource syncFriendList:userId
                         complete:^(NSMutableArray *friends){
                         }];
    dispatch_async(dispatch_get_main_queue(), ^{
        RCDMainTabBarViewController *mainTabBarVC = [[RCDMainTabBarViewController alloc] init];
        RCDNavigationViewController *rootNavi =
        [[RCDNavigationViewController alloc] initWithRootViewController:mainTabBarVC];
        [UIApplication sharedApplication].delegate.window.rootViewController = rootNavi;
    });
}

- (void)retryConnectionFailed {
    [[RCIM sharedRCIM] disconnect];
    [self invalidateRetryTime];
    [hud hide:YES];
}

//停止倒计时？销毁NSTimer
- (void)invalidateRetryTime {
    [self.retryTime invalidate];
    self.retryTime = nil;
}

@end

