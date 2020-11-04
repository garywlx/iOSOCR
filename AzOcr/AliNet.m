//
//  AliNet.m
//  AzOcr
//
//  Created by Autozi01 on 2019/6/5.
//  Copyright © 2019 Autozi01. All rights reserved.
//

#import "AliNet.h"

@implementation AliNet

+ (void) requestOCRCarNo:(NSString *)imageData carNoString:(vinBlock)vb {
    
    NSString *appcode = @"0df99e0c9bb04c5586ed54e0dc916b17";
    NSString *host = @"https://ocrcp.market.alicloudapi.com";
    NSString *path = @"/rest/160601/ocr/ocr_vehicle_plate.json";
    NSString *method = @"POST";
    NSString *querys = @"";
    NSString *url = [NSString stringWithFormat:@"%@%@%@",  host,  path , querys];
//    NSString *bodys =[NSString stringWithFormat: @"{\"image\":\"%@\"，\"configure\":\"{\\\"multi_crop\\\":false}}", imageData];
    NSString *bodys = [NSString stringWithFormat: @"{\"image\":\"%s\"，\"configure\":\"{\\\"multi_crop\\\":false}\"#optional,当设成true时,会做多crop预测，只有当多crop返回的结果一致，并且置信度>0.9时，才返回结果}", imageData.UTF8String];

    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString: url]  cachePolicy:1  timeoutInterval:  5];
    request.HTTPMethod  =  method;
    [request addValue:  [NSString  stringWithFormat:@"APPCODE %@" ,  appcode]  forHTTPHeaderField:  @"Authorization"];
    //根据API的要求，定义相对应的Content-Type
    [request addValue: @"application/json; charset=UTF-8" forHTTPHeaderField: @"Content-Type"];
    NSData *data = [bodys dataUsingEncoding: NSUTF8StringEncoding];
    [request setHTTPBody: data];
    NSURLSession *requestSession = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    NSURLSessionDataTask *task = [requestSession dataTaskWithRequest:request
                                                   completionHandler:^(NSData * _Nullable body , NSURLResponse * _Nullable response, NSError * _Nullable error) {
//                                                       NSLog(@"Response object: %@" , response);
                                                       NSString *bodyString = [[NSString alloc] initWithData:body encoding:NSUTF8StringEncoding];
                                                       if(vb != nil) {
                                                           vb(bodyString);
                                                       }
                                                       //打印应答中的body
                                                       NSLog(@"Response body: %@" , bodyString);
                                                   }];
    
    [task resume];
}

+ (void) requestOCRVin:(NSString * _Nullable )imageData vinCodeString:(vinBlock) vb
{
//     __block NSData *res = nil;
    NSString *appcode = @"0df99e0c9bb04c5586ed54e0dc916b17";
    NSString *host = @"https://vin.market.alicloudapi.com";
    NSString *path = @"/api/predict/ocr_vin";
    NSString *method = @"POST";
    NSString *querys = @"";
    NSString *url = [NSString stringWithFormat:@"%@%@%@",  host,  path , querys];
    NSString *bodys = [NSString stringWithFormat:@"{\"image\":\"%s\"}",  imageData.UTF8String];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString: url]  cachePolicy:1  timeoutInterval:  5];
    request.HTTPMethod  =  method;
    [request addValue:  [NSString  stringWithFormat:@"APPCODE %@" ,  appcode]  forHTTPHeaderField:  @"Authorization"];
    //根据API的要求，定义相对应的Content-Type
    [request addValue: @"application/json; charset=UTF-8" forHTTPHeaderField: @"Content-Type"];
    NSData *data = [bodys dataUsingEncoding: NSUTF8StringEncoding];
    [request setHTTPBody: data];
    NSURLSession *requestSession = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    NSURLSessionDataTask *task = [requestSession dataTaskWithRequest:request
                                                   completionHandler:^(NSData * _Nullable body , NSURLResponse * _Nullable response, NSError * _Nullable error) {
                                                       
//                                                       NSLog(@"Response object: %@" , response);
                                                       NSString *bodyString = [[NSString alloc] initWithData:body encoding:NSUTF8StringEncoding];
//                                                       res = bodyString;
                                                       //打印应答中的body
                                                       if(vb != nil) {
                                                           vb(bodyString);
                                                       }
                                                       NSLog(@"Response body: %@" , bodyString);
                                                   }];
    
    [task resume];
}


+ (void) requestOCRVin_bd:(NSString * _Nullable )imageData vinCodeString:(vinBlock) vb
{
//     __block NSData *res = nil;
//    NSString *appcode = @"541f7076dcd54e3ab8df72008a11ebe4";
    NSString *host = @"https://aip.baidubce.com";
    NSString *path = @"/rest/2.0/ocr/v1/vin_code";
    NSString *access_token = @"?access_token=24.1625fdb8cee36066b31794ed20832d58.2592000.1606967795.282335-22918788";
    NSString *method = @"POST";
//    NSString *querys = @"";
    NSString *bodys = [NSString stringWithFormat:@"?image=%s",  imageData.UTF8String];
    NSString *url = [NSString stringWithFormat:@"%@%@%@%@",  host,  path , access_token, bodys];
//    NSString *bodys = [NSString stringWithFormat:@"{\"image\"=\"%s\"}",  imageData.UTF8String];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString: url]  cachePolicy:1  timeoutInterval:  5];
    request.HTTPMethod  =  method;
    
//    [request addValue:  [NSString  stringWithFormat:@"access_token=%@" ,  appcode]  forHTTPHeaderField:  @"Authorization"];
    
    //根据API的要求，定义相对应的Content-Type
    [request addValue: @"application/json; charset=UTF-8" forHTTPHeaderField: @"Content-Type"];
//    NSData *data = [bodys dataUsingEncoding: NSUTF8StringEncoding];
//    [request setHTTPBody: data];
    NSURLSession *requestSession = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    NSURLSessionDataTask *task = [requestSession dataTaskWithRequest:request
                                                   completionHandler:^(NSData * _Nullable body , NSURLResponse * _Nullable response, NSError * _Nullable error) {
                                                       
//                                                       NSLog(@"Response object: %@" , response);
                                                       NSString *bodyString = [[NSString alloc] initWithData:body encoding:NSUTF8StringEncoding];
//                                                       res = bodyString;
                                                       //打印应答中的body
                                                       if(vb != nil) {
                                                           vb(bodyString);
                                                       }
                                                       NSLog(@"Response body: %@" , bodyString);
                                                   }];
    
    [task resume];
}


@end
