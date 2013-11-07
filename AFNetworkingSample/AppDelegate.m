//
//  AppDelegate.m
//  AFNetworkingSample
//
//  Created by yuta hirakawa on 2013/07/08.
//  Copyright (c) 2013年 yhirakawa. All rights reserved.
//

#import "AppDelegate.h"
#import "AFNetworking.h"
#import "DDTTYLogger.h"
#import "CustomLogFileManager.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // DDLog初期設定
    CustomLogFileManager *logFileManager = [[CustomLogFileManager alloc] init];
	// ファイルにログを出力
	DDFileLogger *fileLogger = [[DDFileLogger alloc] initWithLogFileManager:logFileManager];
    // 一日に一回ログファイルを更新
	// fileLogger.rollingFrequency =   60 * 60 * 24;
    // 10秒に一回ログファイルを更新
    fileLogger.rollingFrequency =   10;
    // ログファイルを残す数
	fileLogger.logFileManager.maximumNumberOfLogFiles = 7;
    // Xcodeのコンソールにログを出力
	[DDLog addLogger:[DDTTYLogger sharedInstance]];
	[DDLog addLogger:fileLogger];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    // ios標準ボタンを作成
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    // 配置を決定 (x位置, y位置, 横幅, 高さ)
    [btn setFrame :CGRectMake(50, 100, 80, 40)];
    // ボタンの文字列を指定
    [btn setTitle :@"Get json!" forState:UIControlStateNormal];
    // ボタンを押下した際のイベントを指定
    [btn addTarget:self
            action:@selector(getJson:) forControlEvents:UIControlEventTouchUpInside];
    // ボタンをwindowに追加
    [self.window addSubview:btn];
    
    // ボタンと同じように結果表示のためにUILabel追加
    self.label = [[UILabel alloc] init];
    [self.label setFrame:CGRectMake(50, 200, 200, 30)];
    [self.label setText:@"Please push button"];
    [self.window addSubview:self.label];
    [self.window makeKeyAndVisible];
    
    return YES;
}


-(void)getJson:(UIButton*)button{
    // ネットワーク状態を確認する
    AFHTTPClient *httpClient = [AFHTTPClient clientWithBaseURL:[NSURL URLWithString:@"http://google.com"]];
    NSLog(@"Network reach %d",[httpClient networkReachabilityStatus]);
    // networkReachabilityStatusには下記状態がある
    // AFNetworkReachabilityStatusReachableViaWiFi wifi
    // AFNetworkReachabilityStatusReachableViaWWAN 3G
    // AFNetworkReachabilityStatusNotReachable     繋がってない
    // ネットワークに繋がっていない場合はアラートを表示する
    if ( [httpClient networkReachabilityStatus] == AFNetworkReachabilityStatusNotReachable ) {
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:@""
                              message:@"ネットワークに繋がっていません\r\n設定をお確かめの上、もう一度お試し下さい。"
                              delegate:nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    // open apiを使ってjsonを取得
    NSURL *url = [NSURL URLWithString:@"http://clip.eventcast.jp/api/v1/Search?Keyword=Google&Format=json"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setTimeoutInterval:1]; // ios6からタイムアウト設定が行える
    // content typeを指定
    [AFJSONRequestOperation addAcceptableContentTypes:[NSSet setWithObject:@"text/html"]];
    AFJSONRequestOperation *operation =
    [AFJSONRequestOperation JSONRequestOperationWithRequest:request
                                                    success:^(NSURLRequest *request, NSHTTPURLResponse *response, id json) {
                                                        // 成功した場合
                                                        // UILabelに表示 AFNetworkingはjsonを使いやすい形に渡してくれる
                                                        [self.label setText:
                                                         [NSString stringWithFormat:
                                                          @"TotalResult : %@", [json valueForKeyPath:@"TotalResult"]
                                                         ]
                                                        ];
                                                        DDLogInfo(@"TotalResult : %@", [json valueForKeyPath:@"TotalResult"]);
                                                    } failure:^(NSURLRequest *req, NSHTTPURLResponse *res, NSError *e, id json) {
                                                        // 失敗した場合、この時点でネットワークに繋がっていない、タイムアウト、urlが間違っている等でここに来る
                                                        // NSLog(@"%@", e.localizedDescription);
                                                        DDLogError(@"%@", e.localizedDescription);
                                                    }];
    [operation start];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
