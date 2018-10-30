//
//  LoginViewController.m
//  RongCloud
//
//  Created by Liv on 14/11/5.
//  Copyright (c) 2014年 RongCloud. All rights reserved.
//
#import "RCDLoginViewController_New.h"
#import "AFHttpTool.h"
#import "AppkeyModel.h"
#import "MBProgressHUD.h"
#import "RCAnimatedImagesView.h"
#import "RCDCommonDefine.h"
#import "RCDFindPswViewController.h"
#import "RCDHttpTool.h"
#import "RCDMainTabBarViewController.h"
#import "RCDNavigationViewController.h"
#import "RCDRCIMDataSource.h"
#import "RCDRegisterViewController.h"
#import "RCDRegisterViewController_New.h"
#import "RCDSettingServerUrlViewController.h"
#import "RCDSettingUserDefaults.h"
#import "RCDTextFieldValidate.h"
#import "RCDUtilities.h"
#import "RCDataBaseManager.h"
#import "RCUnderlineTextField.h"
#import "SelectAppKeyViewController.h"
#import "UIColor+RCColor.h"
#import "UITextFiled+Shake.h"
#import <RongIMKit/RongIMKit.h>
#import "ToastUtil.h"

@interface RCDLoginViewController_New () <UITextFieldDelegate, RCIMConnectionStatusDelegate, UIAlertViewDelegate>

@property(retain, nonatomic) IBOutlet RCAnimatedImagesView *animatedImagesView;

@property(weak, nonatomic) IBOutlet UITextField *emailTextField;

@property(weak, nonatomic) IBOutlet UITextField *pwdTextField;

@property(nonatomic, strong) NSTimer *retryTime;

@property(nonatomic, strong) UIView *headBackground;
@property(nonatomic, strong) UIImageView *rongLogo;
@property(nonatomic, strong) UIView *inputBackground;
@property(nonatomic, strong) UIView *statusBarView;
@property(nonatomic, strong) UILabel *errorMsgLb;
@property(nonatomic, strong) UITextField *passwordTextField;

@property(nonatomic, strong) UIButton *settingButton;

@property(nonatomic, strong) AppkeyModel *currentModel;

@property(nonatomic) int loginFailureTimes;
@property(nonatomic) BOOL rcDebug;

@property(nonatomic, strong) NSString *loginUserName;
@property(nonatomic, strong) NSString *loginUserId;
@property(nonatomic, strong) NSString *loginToken;
@property(nonatomic, strong) NSString *loginPassword;


//新加
//上方文字
@property(nonatomic, strong) UILabel *topLabel;
//手机号码一行
@property(nonatomic, strong) UIView *phoneBg;
@property(nonatomic, strong) UIImageView *quhaoIV;
@property(nonatomic, strong) UILabel *quhaoLabel;
@property(nonatomic, strong) UITextField *phoneTextField;
@property(nonatomic, strong) UIView *phoneLine;
//验证码一行
@property(nonatomic, strong) UIView *codeBg;
@property(nonatomic, strong) UITextField *codeTextField;
@property(strong, nonatomic) IBOutlet UILabel *countDownLable;
@property(strong, nonatomic) IBOutlet UIButton *getCodeButton;
@property(nonatomic, strong) UIView *codeLine;
@property(nonatomic, strong) IBOutlet UIButton *loginButton;
//切换验证码或密码登录方式、忘记密码一行
@property(nonatomic, strong) UIView *switchBg;
@property(strong, nonatomic) IBOutlet UIButton *switchLoginButton;
@property(strong, nonatomic) IBOutlet UIButton *forgetPasswordButton;

//保存手机号、验证码或密码的值
@property(nonatomic, strong) NSString *phoneString;
@property(nonatomic, strong) NSString *codeString;
@property(nonatomic, strong) NSString *codeToken;
//验证码登录还是密码登录
@property(nonatomic) BOOL isCodeLogin;


@end

@implementation RCDLoginViewController_New{
    NSTimer *_CountDownTimer;
    int _Seconds;
}
#define UserTextFieldTag 1000
#define PassWordFieldTag 1001
@synthesize animatedImagesView = _animatedImagesView;
@synthesize inputBackground = _inputBackground;
MBProgressHUD *hud;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSLog(@"RCDLoginViewController_New viewDidLoad");
    
    self.rcDebug = NO;
#if RCDPrivateCloudManualMode
    self.rcDebug = YES;
#endif

    _loginFailureTimes = 0;

    [self.navigationController setNavigationBarHidden:YES animated:YES];

    _isCodeLogin = YES;
    
    [self viewDidLoadNew];
    
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

- (BOOL)textFieldShouldClear:(UITextField *)textField {
    switch (textField.tag) {
    case UserTextFieldTag:
        [DEFAULTS removeObjectForKey:@"userName"];
        self.passwordTextField.text = nil;
    case PassWordFieldTag:
        [DEFAULTS removeObjectForKey:@"userPwd"];
        break;
    default:
        break;
    }
    return YES;
}

//键盘升起时动画
- (void)keyboardWillShow:(NSNotification *)notif {

    CATransition *animation = [CATransition animation];
    animation.type = kCATransitionFade;
    animation.duration = 0.25;
    [_rongLogo.layer addAnimation:animation forKey:nil];

    _rongLogo.hidden = YES;

    [UIView animateWithDuration:0.25
                     animations:^{

                         self.view.frame =
                             CGRectMake(0.f, -50, self.view.frame.size.width, self.view.frame.size.height);
                         _headBackground.frame = CGRectMake(0, 70, self.view.bounds.size.width, 50);
                         _statusBarView.frame = CGRectMake(0.f, 50, self.view.frame.size.width, 20);
                     }
                     completion:nil];
}

//键盘关闭时动画
- (void)keyboardWillHide:(NSNotification *)notif {
    CATransition *animation = [CATransition animation];
    animation.type = kCATransitionFade;
    animation.duration = 0.25;
    [_rongLogo.layer addAnimation:animation forKey:nil];

    _rongLogo.hidden = NO;
    [UIView animateWithDuration:0.25
                     animations:^{
                         self.view.frame =
                             CGRectMake(0.f, 0.f, self.view.frame.size.width, self.view.frame.size.height);
                         CGRectMake(0, -100, self.view.bounds.size.width, 50);
                         _headBackground.frame = CGRectMake(0, -100, self.view.bounds.size.width, 50);
                         _statusBarView.frame = CGRectMake(0.f, 0, self.view.frame.size.width, 20);
                     }
                     completion:nil];
}

//关于内存释放的处理
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    NSString *userName = [(UITextField *)[self.view viewWithTag:UserTextFieldTag] text];
    NSRange foundObj = [userName rangeOfString:@"@" options:NSCaseInsensitiveSearch];
    if (foundObj.length > 0) {
        UITextField *PhoneNumber = (UITextField *)[self.view viewWithTag:UserTextFieldTag];
        PhoneNumber.text = @"";
        UITextField *Password = (UITextField *)[self.view viewWithTag:PassWordFieldTag];
        Password.text = @"";
    }
    if (userName.length > 0) {
        [(UITextField *)[self.view viewWithTag:UserTextFieldTag] setFont:[UIFont fontWithName:@"Heiti SC" size:25.0]];
    }
    [super viewWillAppear:animated];
    [self.animatedImagesView startAnimating];
    if (self.rcDebug) {
        [self.navigationController setNavigationBarHidden:YES animated:YES];
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self invalidateRetryTime];
    [self.animatedImagesView stopAnimating];
}

/*阅读用户协议*/
- (void)userProtocolEvent {
}

- (void)settingEvent {
    RCDSettingServerUrlViewController *temp = [[RCDSettingServerUrlViewController alloc] init];
    [self.navigationController pushViewController:temp animated:YES];
}

/*注册*/
- (void)registerEvent {
    RCDRegisterViewController *temp = [[RCDRegisterViewController alloc] init];
    [self.navigationController pushViewController:temp animated:YES];
}

/*找回密码*/
- (void)forgetPswEvent {
    RCDFindPswViewController *temp = [[RCDFindPswViewController alloc] init];
    [self.navigationController pushViewController:temp animated:YES];
}
/**
 *  获取默认用户
 *
 *  @return 是否获取到数据
 */
- (BOOL)getDefaultUser {
    NSString *userName = [[NSUserDefaults standardUserDefaults] objectForKey:@"userName"];
    NSString *userPwd = [[NSUserDefaults standardUserDefaults] objectForKey:@"userPwd"];
    return userName && userPwd;
}
/*获取用户账号*/
- (NSString *)getDefaultUserName {
    NSString *defaultUser = [[NSUserDefaults standardUserDefaults] objectForKey:@"userName"];
    return defaultUser;
}

/*获取用户密码*/
- (NSString *)getDefaultUserPwd {
    NSString *defaultUserPwd = [[NSUserDefaults standardUserDefaults] objectForKey:@"userPwd"];
    return defaultUserPwd;
}

- (IBAction)actionGetCode:(id)sender {
    
}

//点击登录
- (IBAction)actionLogin:(id)sender {
    //获取手机号码，验证码或密码
    _phoneString = [(UITextField *)[self.view viewWithTag:UserTextFieldTag] text];
    _codeString = [(UITextField *)[self.view viewWithTag:PassWordFieldTag] text];

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
    if(_isCodeLogin){
        [self codeLogin]; //验证码登录
    }else{
        [self passwordLogin]; //密码登录
    }
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
    [AFHttpTool getUserInfo:userId
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
    [[RCIM sharedRCIM] connectWithToken:token
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
                _errorMsgLb.text = [NSString stringWithFormat:@"登录失败！Status: %zd", status];
                [_pwdTextField shake];

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
                         _errorMsgLb.text = @"无法连接到服务器！";
                     });
                 }];
            }else{
                //自己加的，等待补充
                NSLog(@"尝试过一次了，不尝试第二次了");
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
            self.errorMsgLb.text = @"当前网络不可用，请检查！";
        } else if (status == ConnectionStatus_KICKED_OFFLINE_BY_OTHER_CLIENT) {
            self.errorMsgLb.text = @"您的帐号在别的设备上登录，您被迫下线！";
        } else if (status == ConnectionStatus_TOKEN_INCORRECT) {
            NSLog(@"Token无效");
            self.errorMsgLb.text = @"无法连接到服务器！";
            if (self.loginFailureTimes < 1) {
                self.loginFailureTimes++;
                [AFHttpTool getTokenSuccess:^(id response) {
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
                            self.errorMsgLb.text = @"无法连接到服务器！";
                        });
                    }];
            }
        } else {
            NSLog(@"RCConnectErrorCode is %zd", status);
        }
    });
}

- (NSUInteger)animatedImagesNumberOfImages:(RCAnimatedImagesView *)animatedImagesView {
    return 2;
}

- (UIImage *)animatedImagesView:(RCAnimatedImagesView *)animatedImagesView imageAtIndex:(NSUInteger)index {
    return [UIImage imageNamed:@"deng_lu_bei_jing.png"];
}

#pragma mark - UI

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return (toInterfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (void)viewDidUnload {
    [self setAnimatedImagesView:nil];

    [super viewDidUnload];
}

//1、这个类被release的时候会被调用；
//2、这个对象的retain count为0的时候会被调用；或者说一个对象或者类被置为nil的时候；
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
}




//旧的函数
- (void)viewDidLoadOld {
    //    self.view.translatesAutoresizingMaskIntoConstraints = YES;
    //添加动态图
    self.animatedImagesView = [[RCAnimatedImagesView alloc]
                               initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
    [self.view addSubview:self.animatedImagesView];
    self.animatedImagesView.delegate = self;
    
    //添加头部内容
    _headBackground = [[UIView alloc] initWithFrame:CGRectMake(0, -100, self.view.bounds.size.width, 50)];
    _headBackground.userInteractionEnabled = YES;
    _headBackground.backgroundColor = [[UIColor alloc] initWithRed:0 green:0 blue:0 alpha:0.2];
    [self.view addSubview:_headBackground];
    
    UIButton *registerHeadButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 80, 50)];
    [registerHeadButton setTitle:@"找回密码" forState:UIControlStateNormal];
    [registerHeadButton setTitleColor:[[UIColor alloc] initWithRed:153 green:153 blue:153 alpha:0.5]
                             forState:UIControlStateNormal];
    registerHeadButton.titleLabel.font = [UIFont systemFontOfSize:16];
    [registerHeadButton.titleLabel setFont:[UIFont fontWithName:@"Heiti SC" size:14.0]];
    [registerHeadButton addTarget:self action:@selector(forgetPswEvent) forControlEvents:UIControlEventTouchUpInside];
    
    [_headBackground addSubview:registerHeadButton];
    
    //添加图标
    UIImage *rongLogoSmallImage = [UIImage imageNamed:@"title_logo_small"];
    UIImageView *rongLogoSmallImageView =
    [[UIImageView alloc] initWithFrame:CGRectMake(self.view.bounds.size.width / 2 - 60, 5, 100, 40)];
    [rongLogoSmallImageView setImage:rongLogoSmallImage];
    
    [rongLogoSmallImageView setContentScaleFactor:[[UIScreen mainScreen] scale]];
    rongLogoSmallImageView.contentMode = UIViewContentModeScaleAspectFit;
    rongLogoSmallImageView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    rongLogoSmallImageView.clipsToBounds = YES;
    [_headBackground addSubview:rongLogoSmallImageView];
    
    //顶部按钮
    UIButton *forgetPswHeadButton =
    [[UIButton alloc] initWithFrame:CGRectMake(self.view.bounds.size.width - 80, 0, 70, 50)];
    [forgetPswHeadButton setTitle:@"新用户" forState:UIControlStateNormal];
    [forgetPswHeadButton setTitleColor:[[UIColor alloc] initWithRed:153 green:153 blue:153 alpha:0.5]
                              forState:UIControlStateNormal];
    [forgetPswHeadButton.titleLabel setFont:[UIFont fontWithName:@"Heiti SC" size:14.0]];
    [forgetPswHeadButton addTarget:self action:@selector(registerEvent) forControlEvents:UIControlEventTouchUpInside];
    [_headBackground addSubview:forgetPswHeadButton];
    
    UIImage *rongLogoImage = [UIImage imageNamed:@"login_logo"];
    _rongLogo = [[UIImageView alloc] initWithImage:rongLogoImage];
    _rongLogo.contentMode = UIViewContentModeScaleAspectFit;
    _rongLogo.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:_rongLogo];
    
    //中部内容输入区
    _inputBackground = [[UIView alloc] initWithFrame:CGRectZero];
    _inputBackground.translatesAutoresizingMaskIntoConstraints = NO;
    _inputBackground.userInteractionEnabled = YES;
    [self.view addSubview:_inputBackground];
    _errorMsgLb = [[UILabel alloc] initWithFrame:CGRectZero];
    _errorMsgLb.text = @"";
    _errorMsgLb.font = [UIFont fontWithName:@"Heiti SC" size:12.0];
    _errorMsgLb.translatesAutoresizingMaskIntoConstraints = NO;
    _errorMsgLb.textColor = [UIColor colorWithRed:204.0f / 255.0f green:51.0f / 255.0f blue:51.0f / 255.0f alpha:1];
    [self.view addSubview:_errorMsgLb];
    
    //用户名
    RCUnderlineTextField *userNameTextField = [[RCUnderlineTextField alloc] initWithFrame:CGRectZero];
    userNameTextField.backgroundColor = [UIColor clearColor];
    userNameTextField.tag = UserTextFieldTag;
    userNameTextField.delegate = self;
    //_account.placeholder=[NSString stringWithFormat:@"Email"];
    UIColor *color = [UIColor whiteColor];
    userNameTextField.attributedPlaceholder =
    [[NSAttributedString alloc] initWithString:@"手机号" attributes:@{NSForegroundColorAttributeName : color}];
    userNameTextField.textColor = [UIColor whiteColor];
    userNameTextField.text = [self getDefaultUserName];
    userNameTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    userNameTextField.adjustsFontSizeToFitWidth = YES;
    userNameTextField.keyboardType = UIKeyboardTypeNumberPad;
    
    [_inputBackground addSubview:userNameTextField];
    
    //密码
    RCUnderlineTextField *passwordTextField = [[RCUnderlineTextField alloc] initWithFrame:CGRectZero];
    passwordTextField.tag = PassWordFieldTag;
    passwordTextField.textColor = [UIColor whiteColor];
    passwordTextField.returnKeyType = UIReturnKeyDone;
    passwordTextField.secureTextEntry = YES;
    passwordTextField.delegate = self;
    // passwordTextField.delegate = self;
    passwordTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    
    passwordTextField.attributedPlaceholder =
    [[NSAttributedString alloc] initWithString:@"密码" attributes:@{NSForegroundColorAttributeName : color}];
    // passwordTextField.text = [self getDefaultUserPwd];
    [_inputBackground addSubview:passwordTextField];
    passwordTextField.text = [self getDefaultUserPwd];
    self.passwordTextField = passwordTextField;
    
    // UIEdgeInsets buttonEdgeInsets = UIEdgeInsetsMake(0, 7.f, 0, 7.f);
    UIButton *loginButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [loginButton addTarget:self action:@selector(actionLogin:) forControlEvents:UIControlEventTouchUpInside];
    [loginButton setBackgroundImage:[UIImage imageNamed:@"login_button"] forState:UIControlStateNormal];
    loginButton.imageView.contentMode = UIViewContentModeCenter;
    loginButton.translatesAutoresizingMaskIntoConstraints = NO;
    [_inputBackground addSubview:loginButton];
    
    //设置按钮
    UIButton *settingButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [settingButton setTitle:@"私有云设置" forState:UIControlStateNormal];
    [settingButton setTitleColor:[[UIColor alloc] initWithRed:153 green:153 blue:153 alpha:0.5]
                        forState:UIControlStateNormal];
    [settingButton.titleLabel setFont:[UIFont fontWithName:@"Heiti SC" size:17.0]];
    [settingButton addTarget:self action:@selector(settingEvent) forControlEvents:UIControlEventTouchUpInside];
    settingButton.translatesAutoresizingMaskIntoConstraints = NO;
    [_inputBackground addSubview:settingButton];
    self.settingButton = settingButton;
    settingButton.hidden = !self.rcDebug;
    
    UIButton *userProtocolButton = [[UIButton alloc] initWithFrame:CGRectZero];
    //    [userProtocolButton setTitle:@"阅读用户协议"
    //    forState:UIControlStateNormal];
    [userProtocolButton setTitleColor:[[UIColor alloc] initWithRed:153 green:153 blue:153 alpha:0.5]
                             forState:UIControlStateNormal];
    
    [userProtocolButton.titleLabel setFont:[UIFont fontWithName:@"Heiti SC" size:14.0]];
    [userProtocolButton addTarget:self
                           action:@selector(userProtocolEvent)
                 forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:userProtocolButton];
    
    //底部按钮区
    UIView *bottomBackground = [[UIView alloc] initWithFrame:CGRectZero];
    UIButton *registerButton = [[UIButton alloc] initWithFrame:CGRectMake(0, -16, 80, 50)];
    [registerButton setTitle:@"找回密码" forState:UIControlStateNormal];
    [registerButton setTitleColor:[[UIColor alloc] initWithRed:153 green:153 blue:153 alpha:0.5]
                         forState:UIControlStateNormal];
    [registerButton.titleLabel setFont:[UIFont fontWithName:@"Heiti SC" size:14.0]];
    [registerButton addTarget:self action:@selector(forgetPswEvent) forControlEvents:UIControlEventTouchUpInside];
    
    [bottomBackground addSubview:registerButton];
    
    UIButton *forgetPswButton =
    [[UIButton alloc] initWithFrame:CGRectMake(self.view.bounds.size.width - 100, -16, 80, 50)];
    [forgetPswButton setTitle:@"新用户" forState:UIControlStateNormal];
    [forgetPswButton setTitleColor:[[UIColor alloc] initWithRed:153 green:153 blue:153 alpha:0.5]
                          forState:UIControlStateNormal];
    [forgetPswButton.titleLabel setFont:[UIFont fontWithName:@"Heiti SC" size:14.0]];
    [forgetPswButton addTarget:self action:@selector(registerEvent) forControlEvents:UIControlEventTouchUpInside];
    [bottomBackground addSubview:forgetPswButton];
    
    CGRect screenBounds = self.view.frame;
    UILabel *footerLabel = [[UILabel alloc] init];
    footerLabel.textAlignment = NSTextAlignmentCenter;
    footerLabel.frame = CGRectMake(screenBounds.size.width / 2 - 100, -2, 200, 21);
    footerLabel.text = @"Powered by RongCloud";
    [footerLabel setFont:[UIFont systemFontOfSize:12.f]];
    [footerLabel setTextColor:[UIColor colorWithHexString:@"484848" alpha:1.0]];
    [bottomBackground addSubview:footerLabel];
    
    [self.view addSubview:bottomBackground];
    
    bottomBackground.translatesAutoresizingMaskIntoConstraints = NO;
    userProtocolButton.translatesAutoresizingMaskIntoConstraints = NO;
    passwordTextField.translatesAutoresizingMaskIntoConstraints = NO;
    userNameTextField.translatesAutoresizingMaskIntoConstraints = NO;
    
    //添加约束
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:bottomBackground
                                                          attribute:NSLayoutAttributeBottom
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeBottom
                                                         multiplier:1.0
                                                           constant:20]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_rongLogo
                                                          attribute:NSLayoutAttributeCenterX
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeCenterX
                                                         multiplier:1.0
                                                           constant:0]];
    
    NSDictionary *views =
    NSDictionaryOfVariableBindings(_errorMsgLb, _rongLogo, _inputBackground, userProtocolButton, bottomBackground);
    
    NSArray *viewConstraints = [[[[[[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-41-[_inputBackground]-41-|"
                                                                            options:0
                                                                            metrics:nil
                                                                              views:views]
                                    arrayByAddingObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-70-[_rongLogo(100)]-10-[_"
                                                                   @"errorMsgLb(==10)]-20-[_"
                                                                   @"inputBackground(320)]-20-["
                                                                   @"userProtocolButton(==20)]"
                                                                                                          options:0
                                                                                                          metrics:nil
                                                                                                            views:views]]
                                   arrayByAddingObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[bottomBackground(==50)]"
                                                                                                         options:0
                                                                                                         metrics:nil
                                                                                                           views:views]]
                                  arrayByAddingObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-10-[bottomBackground]-10-|"
                                                                                                        options:0
                                                                                                        metrics:nil
                                                                                                          views:views]]
                                 arrayByAddingObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-40-[_errorMsgLb]-10-|"
                                                                                                       options:0
                                                                                                       metrics:nil
                                                                                                         views:views]]
                                arrayByAddingObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[_rongLogo(100)]"
                                                                                                      options:0
                                                                                                      metrics:nil
                                                                                                        views:views]];
    
    [self.view addConstraints:viewConstraints];
    
    NSLayoutConstraint *userProtocolLabelConstraint = [NSLayoutConstraint constraintWithItem:userProtocolButton
                                                                                   attribute:NSLayoutAttributeCenterX
                                                                                   relatedBy:NSLayoutRelationEqual
                                                                                      toItem:self.view
                                                                                   attribute:NSLayoutAttributeCenterX
                                                                                  multiplier:1.f
                                                                                    constant:0];
    [self.view addConstraint:userProtocolLabelConstraint];
    NSDictionary *inputViews =
    NSDictionaryOfVariableBindings(userNameTextField, passwordTextField, loginButton, settingButton);
    
    NSArray *inputViewConstraints = [[[[[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[userNameTextField]|"
                                                                                options:0
                                                                                metrics:nil
                                                                                  views:inputViews]
                                        arrayByAddingObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[passwordTextField]|"
                                                                                                              options:0
                                                                                                              metrics:nil
                                                                                                                views:inputViews]]
                                       arrayByAddingObjectsFromArray:
                                       [NSLayoutConstraint
                                        constraintsWithVisualFormat:
                                        @"V:|[userNameTextField(60)]-[passwordTextField(60)]-[loginButton(50)]-40-[settingButton(50)]"
                                        options:0
                                        metrics:nil
                                        views:inputViews]]
                                      arrayByAddingObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[loginButton]|"
                                                                                                            options:0
                                                                                                            metrics:nil
                                                                                                              views:inputViews]]
                                     arrayByAddingObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[settingButton]|"
                                                                                                           options:0
                                                                                                           metrics:nil
                                                                                                             views:inputViews]];
    
    [_inputBackground addConstraints:inputViewConstraints];
    
    //    CGPoint footerLabelCenter = footerLabel.center;
    //    settingButton.center = CGPointMake(footerLabelCenter.x, footerLabelCenter.y-12);
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:self.view.window];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:self.view.window];
    _statusBarView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 20)];
    _statusBarView.backgroundColor = [[UIColor alloc] initWithRed:0 green:0 blue:0 alpha:0.2];
    [self.view addSubview:_statusBarView];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:NO];
    [self.view setNeedsLayout];
    [self.view setNeedsUpdateConstraints];
}


//新加的函数
- (void)viewDidLoadNew {
    self.view.translatesAutoresizingMaskIntoConstraints = YES;
    
    //添加动态图
    self.animatedImagesView = [[RCAnimatedImagesView alloc]
                               initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
    [self.view addSubview:self.animatedImagesView];
    self.animatedImagesView.delegate = self;
    
    //顶部文字
    [self topLabelLayout];
    
    //手机号码一行
    [self phoneNumberLayout];
    
    //手机号码下方横线
    [self phoneLineLayout];
    
    //验证码或密码一行
    [self codeLayout];
    
    //验证码或密码下方的横线
    [self codeLineLayout];
    
    //登录按钮
    [self loginLayout];
    
    //切换登录方式、忘记密码
    [self switchLayout];
    
    //整体约束
    [self constraintAllView];
    
    //其他初始化设置
    [self otherInit];
}

//顶部文字布局
- (void)topLabelLayout {
    _topLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _topLabel.textAlignment = NSTextAlignmentCenter;
    _topLabel.text = @"欢迎加入软件";
    [_topLabel setFont:[UIFont systemFontOfSize:25.f]];
    [_topLabel setTextColor:[UIColor colorWithHexString:@"030303" alpha:1.0]];
    _topLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:_topLabel];
}

//手机号码一行布局
- (void)phoneNumberLayout {
    //一整行
    _phoneBg = [[UIView alloc] initWithFrame:CGRectZero];
    _phoneBg.translatesAutoresizingMaskIntoConstraints = NO;
    _phoneBg.userInteractionEnabled = YES;
    //    _phoneBg.backgroundColor = [UIColor colorWithHexString:@"000000" alpha:0.0];
    [self.view addSubview:_phoneBg];
    //加号
    UIImage *quhaoImage = [UIImage imageNamed:@"deng_lu_jia_hao"];
    _quhaoIV = [[UIImageView alloc] initWithImage:quhaoImage];
    _quhaoIV.contentMode = UIViewContentModeScaleAspectFit;
    _quhaoIV.translatesAutoresizingMaskIntoConstraints = NO;
    [_phoneBg addSubview:_quhaoIV];
    //86
    _quhaoLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _quhaoLabel.textAlignment = NSTextAlignmentCenter;
    _quhaoLabel.text = @"86";
    [_quhaoLabel setFont:[UIFont systemFontOfSize:20.f]];
    [_quhaoLabel setTextColor:[UIColor colorWithHexString:@"817777" alpha:1.0]];
    _quhaoLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [_phoneBg addSubview:_quhaoLabel];
    //手机号码输入区域
    _phoneTextField = [[UITextField alloc] initWithFrame:CGRectZero];
    //    _phoneTextField.backgroundColor = [UIColor clearColor];
    _phoneTextField.tag = UserTextFieldTag;
    _phoneTextField.delegate = self;
    //_account.placeholder=[NSString stringWithFormat:@"Email"];
    UIColor *color = [UIColor colorWithHexString:@"C5BABA" alpha:1.0];
    _phoneTextField.attributedPlaceholder =
    [[NSAttributedString alloc] initWithString:@"手机号" attributes:@{NSForegroundColorAttributeName : color}];
    _phoneTextField.textColor = [UIColor colorWithHexString:@"000000" alpha:1.0];
    //    _phoneTextField.text = [self getDefaultUserName];
    _phoneTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    _phoneTextField.font = [UIFont fontWithName:@"Heiti SC" size:20.0];
    _phoneTextField.keyboardType = UIKeyboardTypeNumberPad;
    _phoneTextField.translatesAutoresizingMaskIntoConstraints = NO;
    //添加监听，使输入手机号数字个数不超过11个
    [_phoneTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    [_phoneBg addSubview:_phoneTextField];
    
    //约束
    [self.view addConstraint:[NSLayoutConstraint
                              constraintWithItem:_quhaoIV
                              attribute:NSLayoutAttributeCenterY
                              relatedBy:NSLayoutRelationEqual
                              toItem:_phoneBg
                              attribute:NSLayoutAttributeCenterY
                              multiplier:1.0
                              constant:0]];
    
    NSDictionary *phoneBgDic =
    NSDictionaryOfVariableBindings(_quhaoIV, _quhaoLabel, _phoneTextField);
    NSArray *phoneBgConstraints
    = [[[NSLayoutConstraint
         constraintsWithVisualFormat:
         @"V:|[_quhaoLabel]|" options:0 metrics:nil
         views:phoneBgDic]
        arrayByAddingObjectsFromArray:[NSLayoutConstraint
                                       constraintsWithVisualFormat:
                                       @"V:|[_phoneTextField]|" options:0 metrics:nil views:phoneBgDic]]
       arrayByAddingObjectsFromArray:[NSLayoutConstraint
                                      constraintsWithVisualFormat:
                                      @"H:|[_quhaoIV]-7-[_quhaoLabel]-28-[_phoneTextField(>=30)]|" options:0 metrics:nil views:phoneBgDic]];
    
    [_phoneBg addConstraints:phoneBgConstraints];
}

//手机号码下方横线
- (void)phoneLineLayout {
    _phoneLine = [[UIView alloc] initWithFrame:CGRectZero];
    _phoneLine.translatesAutoresizingMaskIntoConstraints = NO;
    _phoneLine.backgroundColor = [UIColor colorWithHexString:@"979797" alpha:1.0];
    [self.view addSubview:_phoneLine];
}

//验证码或密码一行布局
- (void)codeLayout {
    //一整行
    _codeBg = [[UIView alloc] initWithFrame:CGRectZero];
    _codeBg.translatesAutoresizingMaskIntoConstraints = NO;
    _codeBg.userInteractionEnabled = YES;
    //    _codeBg.backgroundColor = [UIColor colorWithHexString:@"000000" alpha:0.0];
    [self.view addSubview:_codeBg];
    //验证码或密码输入区域
    _codeTextField = [[RCUnderlineTextField alloc] initWithFrame:CGRectZero];
    _codeTextField.backgroundColor = [UIColor clearColor];
    _codeTextField.tag = PassWordFieldTag;
    _codeTextField.delegate = self;
    //_account.placeholder=[NSString stringWithFormat:@"Email"];
    UIColor *color = [UIColor colorWithHexString:@"C5BABA" alpha:1.0];
    _codeTextField.attributedPlaceholder =
    [[NSAttributedString alloc] initWithString:@"输入验证码" attributes:@{NSForegroundColorAttributeName : color}];
    _codeTextField.textColor = [UIColor colorWithHexString:@"000000" alpha:1.0];
    _codeTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    _codeTextField.font = [UIFont fontWithName:@"Heiti SC" size:20.0];
    _codeTextField.keyboardType = UIKeyboardTypeNumberPad;
    _codeTextField.translatesAutoresizingMaskIntoConstraints = NO;
    //添加监听，使输入验证码数字个数不超过11个
    [_codeTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    [_codeBg addSubview:_codeTextField];
    
    //点击获取验证码
    _getCodeButton = [[UIButton alloc] init];
    [_getCodeButton
     setBackgroundColor:[[UIColor alloc] initWithRed:133 / 255.f green:133 / 255.f blue:133 / 255.f alpha:1]];
    [_getCodeButton setTitle:@"发送验证码" forState:UIControlStateNormal];
    [_getCodeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_getCodeButton addTarget:self
                               action:@selector(getVerficationCode)
                     forControlEvents:UIControlEventTouchUpInside];
    _getCodeButton.translatesAutoresizingMaskIntoConstraints = NO;
    [_getCodeButton.titleLabel setFont:[UIFont fontWithName:@"Heiti SC" size:13.0]];
    _getCodeButton.enabled = NO;
    _getCodeButton.layer.masksToBounds = YES;
    _getCodeButton.layer.cornerRadius = 6.f;
    [_codeBg addSubview:_getCodeButton];
    
    //获取验证码倒计时
    _countDownLable = [[UILabel alloc] init];
    _countDownLable.textColor = [UIColor whiteColor];
    [_countDownLable
     setBackgroundColor:[[UIColor alloc] initWithRed:133 / 255.f green:133 / 255.f blue:133 / 255.f alpha:1]];
    _countDownLable.textAlignment = UITextAlignmentCenter;
    [_countDownLable setFont:[UIFont fontWithName:@"Heiti SC" size:13.0]];
    _countDownLable.text = @"60秒后发送";
    _countDownLable.translatesAutoresizingMaskIntoConstraints = NO;
    _countDownLable.hidden = YES;
    _countDownLable.layer.masksToBounds = YES;
    _countDownLable.layer.cornerRadius = 6.f;
    [_codeBg addSubview:_countDownLable];
    
    //约束
    NSDictionary *views =
    NSDictionaryOfVariableBindings(_codeTextField, _getCodeButton, _countDownLable);
    
    NSArray *codeTextField_V= [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_codeTextField]|" options:0 metrics:nil views:views];
    NSArray *getCodeButton_V= [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_getCodeButton]|" options:0 metrics:nil views:views];
    NSArray *countDownLable_V= [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_countDownLable]|" options:0 metrics:nil views:views];
    //下面是getCodeButton和countDownLable位置重叠
    NSArray *codeTextField_getCodeButton_H= [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_codeTextField]-10-[_getCodeButton(95)]|" options:0 metrics:nil views:views];
    NSArray *codeTextField_countDownLable_H= [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_codeTextField]-10-[_countDownLable(95)]|" options:0 metrics:nil views:views];
    
    [_codeBg addConstraints:codeTextField_V];
    [_codeBg addConstraints:getCodeButton_V];
    [_codeBg addConstraints:countDownLable_V];
    [_codeBg addConstraints:codeTextField_getCodeButton_H];
    [_codeBg addConstraints:codeTextField_countDownLable_H];
}

//验证码或密码下方横线
- (void)codeLineLayout {
    _codeLine = [[UIView alloc] initWithFrame:CGRectZero];
    _codeLine.translatesAutoresizingMaskIntoConstraints = NO;
    _codeLine.backgroundColor = [UIColor colorWithHexString:@"979797" alpha:1.0];
    [self.view addSubview:_codeLine];
}

//登录按钮
- (void)loginLayout {
    _loginButton = [[UIButton alloc] init];
    [_loginButton setBackgroundColor:[UIColor colorWithHexString:@"EFF059" alpha:1.0]];
    [_loginButton setTitle:@"登录" forState:UIControlStateNormal];
    [_loginButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_loginButton addTarget:self action:@selector(actionLogin:) forControlEvents:UIControlEventTouchUpInside];
    _loginButton.translatesAutoresizingMaskIntoConstraints = NO;
    [_loginButton.titleLabel setFont:[UIFont fontWithName:@"Heiti SC" size:18.0]];
    _loginButton.layer.masksToBounds = YES;
    _loginButton.layer.cornerRadius = 6.f;
    
    [self.view addSubview:_loginButton];
}

//切换登录方式、忘记密码
- (void)switchLayout {
    //一整行
    _switchBg = [[UIView alloc] initWithFrame:CGRectZero];
    _switchBg.translatesAutoresizingMaskIntoConstraints = NO;
    _switchBg.userInteractionEnabled = YES;
    [self.view addSubview:_switchBg];
    //切换按钮
    _switchLoginButton = [[UIButton alloc] init];
    [_switchLoginButton setTitle:@"密码登录" forState:UIControlStateNormal];
    [_switchLoginButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_switchLoginButton addTarget:self action:@selector(switchCodeOrPassword:) forControlEvents:UIControlEventTouchUpInside];
    _switchLoginButton.translatesAutoresizingMaskIntoConstraints = NO;
    [_switchLoginButton.titleLabel setFont:[UIFont fontWithName:@"Heiti SC" size:15.0]];
    [_switchBg addSubview:_switchLoginButton];
    //忘记密码按钮
    _forgetPasswordButton = [[UIButton alloc] init];
    [_forgetPasswordButton setTitle:@"忘记密码" forState:UIControlStateNormal];
    [_forgetPasswordButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_forgetPasswordButton addTarget:self action:@selector(switchCodeOrPassword:) forControlEvents:UIControlEventTouchUpInside];
    _forgetPasswordButton.translatesAutoresizingMaskIntoConstraints = NO;
    [_forgetPasswordButton.titleLabel setFont:[UIFont fontWithName:@"Heiti SC" size:15.0]];
    [_switchBg addSubview:_forgetPasswordButton];
    //约束
    NSDictionary *views =
    NSDictionaryOfVariableBindings(_switchLoginButton, _forgetPasswordButton);
    
    //密码登录靠左，下面switchLoginButton_H的方式也同样能实现靠左
//    [_switchBg addConstraint:[NSLayoutConstraint
//                              constraintWithItem:_switchLoginButton
//                              attribute:NSLayoutAttributeLeft
//                              relatedBy:NSLayoutRelationEqual
//                              toItem:_switchBg
//                              attribute:NSLayoutAttributeLeft
//                              multiplier:1.0
//                              constant:0]];
    NSArray *switchLoginButton_H = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_switchLoginButton]" options:0 metrics:nil views:views];
    NSArray *switchLoginButton_V = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_switchLoginButton]|" options:0 metrics:nil views:views];
    //忘记密码靠右，下面switchLoginButton_H的方式也同样能实现靠右
//    [_switchBg addConstraint:[NSLayoutConstraint
//                              constraintWithItem:_forgetPasswordButton
//                              attribute:NSLayoutAttributeRight
//                              relatedBy:NSLayoutRelationEqual
//                              toItem:_switchBg
//                              attribute:NSLayoutAttributeRight
//                              multiplier:1.0
//                              constant:0]];
    NSArray *forgetPasswordButton_H = [NSLayoutConstraint constraintsWithVisualFormat:@"H:[_forgetPasswordButton]|" options:0 metrics:nil views:views];
    NSArray *forgetPasswordButton_V = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_forgetPasswordButton]|" options:0 metrics:nil views:views];
    
    [_switchBg addConstraints:switchLoginButton_H];
    [_switchBg addConstraints:switchLoginButton_V];
    [_switchBg addConstraints:forgetPasswordButton_H];
    [_switchBg addConstraints:forgetPasswordButton_V];
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
    
    //指定约束
    NSDictionary *views =
    NSDictionaryOfVariableBindings(_topLabel,_phoneBg,_phoneLine,_codeBg,_codeLine,_loginButton,_switchBg);
    
    NSArray *inputBackground_H= [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-55-[_phoneBg]-55-|" options:0 metrics:nil views:views];
    NSArray *phoneLine_H= [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-55-[_phoneLine]-55-|" options:0 metrics:nil views:views];
    NSArray *codeBg_H= [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-55-[_codeBg]-55-|" options:0 metrics:nil views:views];
    NSArray *codeLine_H= [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-55-[_codeLine]-55-|" options:0 metrics:nil views:views];
    NSArray *loginButton_H= [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-55-[_loginButton]-55-|" options:0 metrics:nil views:views];
    NSArray *switchBg_H= [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-55-[_switchBg]-55-|" options:0 metrics:nil views:views];
    NSArray *all_V= [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-160-[_topLabel]-78-[_phoneBg]-8-[_phoneLine(1)]-30-[_codeBg]-8-[_codeLine(1)]-30-[_loginButton(40)]-20-[_switchBg(20)]" options:0 metrics:nil views:views];
    
    [self.view addConstraints:inputBackground_H];
    [self.view addConstraints:phoneLine_H];
    [self.view addConstraints:codeBg_H];
    [self.view addConstraints:codeLine_H];
    [self.view addConstraints:loginButton_H];
    [self.view addConstraints:switchBg_H];
    [self.view addConstraints:all_V];
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

//监听编辑框事件，限制输入数字个数
-(void)textFieldDidChange:(UITextField * )textField{
    if (textField == _phoneTextField) {
        if (textField.text.length >= 11) {
            textField.text = [textField.text substringToIndex:11];
            _getCodeButton.enabled = YES;
            [_getCodeButton
             setBackgroundColor:[[UIColor alloc] initWithRed:23 / 255.f green:136 / 255.f blue:213 / 255.f alpha:1]];
        }else{
            _getCodeButton.enabled = NO;
            [_getCodeButton
             setBackgroundColor:[[UIColor alloc] initWithRed:133 / 255.f green:133 / 255.f blue:133 / 255.f alpha:1]];
        }
    }else if(textField == _codeTextField){
        if(_isCodeLogin){
            if (textField.text.length > 6) {
                textField.text = [textField.text substringToIndex:6];
            }
        }else{
            if (textField.text.length > 16) {
                textField.text = [textField.text substringToIndex:16];
            }
        }
    }
}

//获取验证码
- (void)getVerficationCode {
    _phoneString = [(UITextField *)[self.view viewWithTag:UserTextFieldTag] text];
    _codeString = [(UITextField *)[self.view viewWithTag:PassWordFieldTag] text];
    if(![self validatePhone]){
        return;
    }
    hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.color = [UIColor colorWithHexString:@"343637" alpha:0.8];
    [hud show:YES];
    
    [AFHttpTool getVerificationCode:@"86" phoneNumber:_phoneString
                            success:^(id response) {
                                [hud hide:YES];
                                NSDictionary *results = response;
                                NSString *code = [NSString stringWithFormat:@"%@", [results objectForKey:@"code"]];
                                if (code.intValue == 200) {
                                    _getCodeButton.hidden = YES;
                                    _countDownLable.hidden = NO;
                                    [self CountDown:60];
                                    NSLog(@"Get verification code successfully");
                                    [ToastUtil showMessage:@"短信已发出,请注意查收" duration:2.0];
                                }else if(code.intValue == 5000){
                                    [ToastUtil showMessage:@"短信发送频率超限" duration:2.0];
                                }else{
                                    [ToastUtil showMessage:@"获取验证码失败，请稍后重试" duration:2.0];
                                }
                            }
                            failure:^(NSError *err) {
                                [hud hide:YES];
                                [ToastUtil showMessage:@"获取验证码失败，请稍后重试" duration:2.0];
                                NSLog(@"%@", err);
                            }];


}

//发送验证码之后的倒计时
- (void)CountDown:(int)seconds {
    _Seconds = seconds;
    _CountDownTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                       target:self
                                                     selector:@selector(timeFireMethod)
                                                     userInfo:nil
                                                      repeats:YES];
}

//倒计时
- (void)timeFireMethod {
    _Seconds--;
    _countDownLable.text = [NSString stringWithFormat:@"%d秒后发送", _Seconds];
    if (_Seconds == 0) {
        [_CountDownTimer invalidate];
        _countDownLable.hidden = YES;
        _getCodeButton.hidden = NO;
        _countDownLable.text = @"60秒后发送";
    }
}

//验证码登录
-(void)codeLogin {
    if ([self validatePhone] && [self validateCode]) {
        hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.color = [UIColor colorWithHexString:@"343637" alpha:0.8];
        hud.labelText = @"登录中...";
        [hud show:YES];//登录完跳转，带个转圈影响体验，仿照请吃饭，将登录按钮置灰不可点
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"UserCookies"];
        //验证验证码是否有效
        [AFHttpTool verifyVerificationCode:@"86"
                               phoneNumber:_phoneString
                          verificationCode:_codeString
                                   success:^(id response) {
                                       NSDictionary *results = response;
                                       NSString *code = [NSString stringWithFormat:@"%@", [results objectForKey:@"code"]];
                                       
                                       if (code.intValue == 200) {
                                           NSDictionary *result = [results objectForKey:@"result"];
                                           _codeToken = [result objectForKey:@"verification_token"];
                                           //验证码验证成功，开始通过返回的验证码token去请求登录
                                           [self codeLoginRequest:_codeToken];
                                       }
                                       if (code.intValue == 1000) {
                                           [hud hide:YES];
                                           [ToastUtil showMessage:@"验证码错误或已过期" duration:2.0];
                                       }
                                       if (code.intValue == 2000) {
                                           [hud hide:YES];
                                           [ToastUtil showMessage:@"验证码错误或已过期" duration:2.0];
                                       }
                                   }
                                   failure:^(NSError *err) {
                                       [hud hide:YES];
                                       [ToastUtil showMessage:@"验证码错误或已过期" duration:2.0];
                                   }];
        
    }
}

//验证码验证成功，开始通过返回的验证码verificationToken去请求登录
-(void)codeLoginRequest:(NSString * )verificationToken {
    //验证码登录
    [AFHttpTool codeLoginWithRegion:@"86" phoneNumber:_phoneString verficationToken:verificationToken
                            success:^(id response) {
                                NSDictionary *results = response;
                                NSString *code = [NSString stringWithFormat:@"%@", [results objectForKey:@"code"]];
                                if (code.intValue == 200) {
                                    NSDictionary *result = [results objectForKey:@"result"];
                                    NSString *token = [result objectForKey:@"token"];
                                    NSString *userId = [result objectForKey:@"id"];
                                    //验证码的verificationToken验证成功后，用返回来的token连接融云服务器
                                    [self loginRongCloud:_phoneString userId:userId token:token];
                                }else if (code.intValue == 3000) {
                                    //用户未注册，进入到完善个人资料页面
                                    [hud hide:YES];
                                    RCDRegisterViewController_New *registerView = [[RCDRegisterViewController_New alloc] init];
                                    registerView.phoneString = _phoneString;
                                    registerView.codeToken = _codeToken;
                                    registerView.loginType = @"code_login";
                                    [self.navigationController pushViewController:registerView animated:YES];
                                    
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

//密码登录
-(void)passwordLogin {
    if ([self validatePhone] && [self validateCode]) {
        hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.color = [UIColor colorWithHexString:@"343637" alpha:0.8];
        hud.labelText = @"登录中...";
        [hud show:YES];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"UserCookies"];
        //        [[RCIM sharedRCIM] initWithAppKey:@"p5tvi9dst25b4"];
        [AFHttpTool loginWithPhone:_phoneString
                          password:_codeString
                            region:@"86"
                           success:^(id response) {
                               if ([response[@"code"] intValue] == 200) {
                                   NSString *token = response[@"result"][@"token"];
                                   NSString *userId = response[@"result"][@"id"];
                                   //密码验证成功后，用返回来的token连接融云服务器
                                   [self loginRongCloud:_phoneString userId:userId token:token];
                               } else {
                                   //关闭HUD
                                   [hud hide:YES];
                                   int _errCode = [response[@"code"] intValue];
                                   NSLog(@"NSError is %d", _errCode);
                                   if (_errCode == 1000) {
                                       _errorMsgLb.text = @"手机号或密码错误！";
                                   }
                                   [_pwdTextField shake];
                               }
                           }
                           failure:^(NSError *err) {
                               [hud hide:YES];
                               _errorMsgLb.text = @"登录失败，请检查网络。";
                           }];
    }
}

//验证手机号码、验证码或密码格式正确性
- (BOOL)validateCode {
    if(_isCodeLogin){
        //验证码登录判断验证码合法性
        if (_codeString == nil || _codeString.length < 4 || _codeString.length > 6) {
            [ToastUtil showMessage:@"请填写4-6位数字验证码" duration:2.0];
            [_codeTextField shake];
            return NO;
        }
    }else{
        //密码登录判断密码合法性
        if (_codeString == nil || _codeString.length < 6 || _codeString.length > 16) {
            [ToastUtil showMessage:@"密码为6-16字符" duration:2.0];
            [_codeTextField shake];
            return NO;
        }
        
        NSRange _range = [_codeString rangeOfString:@" "];
        if (_range.location != NSNotFound) {
            [ToastUtil showMessage:@"密码不能包含空格" duration:2.0];
            [_codeTextField shake];
            return NO;
        }
    }
    return YES;
}

//验证手机号合法性，RCDTextFieldValidate类中的validateMobile是验证手机号码合法性，但感觉有些过时
//下面这个是比较宽的条件，11位数字就行，其实服务端也会检查手机号的合法性，后面得仔细检查规则
- (BOOL)validatePhone {
    if (_phoneString == nil || _phoneString.length != 11) {
        [ToastUtil showMessage:@"请填写正确的手机号码" duration:2.0];
        [_phoneTextField shake];
        return NO;
    }
    return YES;
}

//切换验证码登录、密码登录方式
- (IBAction)switchCodeOrPassword:(id)sender {
    _isCodeLogin = !_isCodeLogin;
    [self setCodeOrPasswordStatus];
}

//两种登录方式设置不同的状态
- (void)setCodeOrPasswordStatus {
    if (_isCodeLogin) {
        [_switchLoginButton setTitle:@"密码登录" forState:UIControlStateNormal];
        _getCodeButton.hidden = NO;
        _codeTextField.text = @"";
        _codeTextField.placeholder = @"输入验证码";
        _codeTextField.keyboardType = UIKeyboardTypeNumberPad;
        _forgetPasswordButton.hidden = YES;
    } else {
        [_switchLoginButton setTitle:@"验证码登录" forState:UIControlStateNormal];
        _getCodeButton.hidden = YES;
        _codeTextField.text = @"";
        _codeTextField.placeholder = @"输入密码";
        _codeTextField.keyboardType = UIKeyboardTypeDefault;
        _forgetPasswordButton.hidden = NO;
    }
}

- (void)setLoginButtonEnable:(BOOL)enable {
    if(enable){
        _loginButton.enabled = YES;
        [_loginButton setBackgroundColor:[UIColor colorWithHexString:@"EFF059" alpha:1.0]];
    }else{
        _loginButton.enabled = YES;
        [_loginButton setBackgroundColor:[UIColor colorWithHexString:@"EEEEE6" alpha:1.80]];
    }
}

@end
