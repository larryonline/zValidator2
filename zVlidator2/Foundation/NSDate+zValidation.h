//
//  NSDate+(zValidation).h
//  zVlidator2
//
//  Created by ZhangZhenNan on 16/5/26.
//  Copyright © 2016年 zhennan.me. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "zRule.h"

@class zRuleForNSDate;
@interface NSDate(zValidation)
+(zRuleForNSDate *)zvAND;
+(zRuleForNSDate *)zvOR;
@end

@interface zRuleForNSDate : zComplexRule
-(instancetype)isToday;
-(instancetype)notToday;

-(instancetype)isYesterday;
-(instancetype)isTomorrow;
@end