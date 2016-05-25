//
//  NSNumber+zValidator.h
//  zVlidator2
//
//  Created by ZhangZhenNan on 16/5/25.
//  Copyright © 2016年 zhennan.me. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "zRule.h"

@class zRuleForNSNumber;

@interface NSNumber(zValidator)
+(zRuleForNSNumber *)zvAND;
+(zRuleForNSNumber *)zvOR;
@end

@interface zRuleForNSNumber : zComplexRule

-(instancetype)isZero;
-(instancetype)notZero;

-(instancetype)isMinus;
-(instancetype)notMinus;

-(instancetype)isPlus;
-(instancetype)notPlus;
@end
