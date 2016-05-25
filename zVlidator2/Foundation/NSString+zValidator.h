//
//  NSString+zValidator.h
//  zVlidator2
//
//  Created by ZhangZhenNan on 16/5/24.
//  Copyright © 2016年 zhennan.me. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "zRule.h"

@class zRuleForNSString;

@interface NSString(zValidator)

+(zRuleForNSString *)zvAND;
+(zRuleForNSString *)zvOR;
@end

@interface zRuleForNSString : zComplexRule
-(instancetype)isEmpty;
-(instancetype)notEmpty;

-(zRuleForNSString *(^)(NSInteger min, NSInteger max))inRange;
-(zRuleForNSString *(^)(NSInteger min, NSInteger max))notInRange;

-(zRuleForNSString *(^)(NSString *content))contains;
-(zRuleForNSString *(^)(NSString *content))notContains;

-(zRuleForNSString *(^)(NSString *format))predicate;
-(zRuleForNSString *(^)(NSString *format))notPredicate;

-(zRuleForNSString *(^)(NSString *regexp))match;
-(zRuleForNSString *(^)(NSString *regexp))notMatch;
@end