//
//  CustomLogFileManager.m
//  AFNetworkingSample
//
//  Created by yuta hirakawa on 2013/07/18.
//  Copyright (c) 2013年 yhirakawa. All rights reserved.
//

#import "CustomLogFileManager.h"
#import "AFNetworking.h"

@implementation CustomLogFileManager

// ログファイルが更新される際に呼ばれる
-(void)didRollAndArchiveLogFile:(NSString *)logFilePath
{
    // ログファイルのパスからログ内容を取得
    DDLogFileInfo *info = [DDLogFileInfo logFileWithPath:logFilePath];
    NSString* content = [NSString stringWithContentsOfFile:info.filePath
                                                  encoding:NSUTF8StringEncoding
                                                     error:NULL];
    // ログを送信
    [self postLogData:content];
}

-(void)postLogData:(NSString *) data
{
    // ログデータを表示するのでここはNSLogを使用する
    NSLog(@"post data : %@", data);
    // ※https://sample.urlは存在しないURLですので、失敗になりますが
    // このようにエラーログ等をサーバに送る事でログ収集が可能です
    NSURL *url = [NSURL URLWithString:@"https://sample.url"];
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:url];
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            data, @"log",
                            nil];
    [httpClient postPath:@"/log/save" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        // 成功時
        NSString *responseStr = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        DDLogVerbose(@"Request Successful, response '%@'", responseStr);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        // 失敗時
        DDLogError(@"[HTTPClient Error]: %@", error.localizedDescription);
    }];
}

@end
