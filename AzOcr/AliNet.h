//
//  AliNet.h
//  AzOcr
//
//  Created by Autozi01 on 2019/6/5.
//  Copyright © 2019 Autozi01. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface AliNet : NSObject
typedef void(^vinBlock)(NSString * );

+ (void) requestOCRCarNo:(NSString *)imageData carNoString:(vinBlock)vb ;

+(void) requestOCRVin:(NSString * _Nullable )imageData vinCodeString:(vinBlock) vb;

+ (void) requestOCRVin_bd:(NSString * _Nullable )imageData vinCodeString:(vinBlock) vb;

@end

NS_ASSUME_NONNULL_END
