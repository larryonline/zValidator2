//
//  NSNumber+zValidator.m
//  zVlidator2
//
//  Created by ZhangZhenNan on 16/5/25.
//  Copyright © 2016年 zhennan.me. All rights reserved.
//

#import "NSNumber+zValidator.h"

@implementation NSNumber(zValidator)

+(zRuleForNSNumber *)zvAND{
    return [zRuleForNSNumber ruleLogicAND];
}

+(zRuleForNSNumber *)zvOR{
    return [zRuleForNSNumber ruleLogicOR];
}

@end

@implementation zRuleForNSNumber

-(BOOL)validate:(id)data{
    if(![data isKindOfClass:[NSNumber class]]){
        [NSException raise:@"INAVAILABLE GIVEN DATA" format:@"data[%@] should be member of NSNumber class", data];
    }
    
    return [super validate:data];
}

-(instancetype)isZero{
    self.is(^BOOL(id data){
        return [@0 isEqualToNumber:data];
    });
    return self;
}

-(instancetype)notZero{
    self.is(^BOOL(id data){
        return ![@0 isEqualToNumber:data];
    });
    return self;
}

-(instancetype)isMinus{
    self.is(^BOOL(id data){
        return 0 > [data doubleValue];
    });
    return self;
}

-(instancetype)notMinus{
    self.is(^BOOL(id data){
        return !(0 > [data doubleValue]);
    });
    return self;
}

-(instancetype)isPlus{
    self.is(^BOOL(id data){
        return 0 < [data doubleValue];
    });
    return self;
}

-(instancetype)notPlus{
    self.is(^BOOL(id data){
        return !(0 < [data doubleValue]);
    });
    return self;
}

@end
