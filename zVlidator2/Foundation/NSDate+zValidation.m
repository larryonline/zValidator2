//
//  NSDate+(zValidation).m
//  zVlidator2
//
//  Created by ZhangZhenNan on 16/5/26.
//  Copyright © 2016年 zhennan.me. All rights reserved.
//

#import "NSDate+zValidation.h"

@implementation NSDate(zValidation)
+(zRuleForNSDate *)zvAND{
    return [zRuleForNSDate ruleLogicAND];
}

+(zRuleForNSDate *)zvOR{
    return [zRuleForNSDate ruleLogicOR];
}
@end

@implementation zRuleForNSDate

-(BOOL)validate:(id)data{
    if(![data isKindOfClass:[NSDate class]]){
        NSLog(@"GIVEN DATA[%@] IS NOT INSTANCE OF NSDate", data);
        return NO;
    }
    return [super validate:data];
}

-(instancetype)isToday{
    self.is(^BOOL(id data){
        return NO;
    });
    return self;
}

-(instancetype)notToday{
    self.is(^BOOL(id data){
        return NO;
    });
    return self;
}

-(instancetype)isYesterday{
    self.is(^BOOL(id data){
        return NO;
    });
    return self;
}

-(instancetype)isTomorrow{
    self.is(^BOOL(id data){
        return NO;
    });
    return self;
}

@end
