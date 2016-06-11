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
        NSLog(@"GIVEN DATA[%@] IS NOT INSTANCE OF NSNumber", data);
        return NO;
    }
    
    return [super validate:data];
}

-(instancetype)isZero{
    self.is(^BOOL(id data){
        return [@0 isEqualToNumber:data];
    });
    [self.children.lastObject setName:@"isZero"];
    return self;
}

-(instancetype)notZero{
    self.is(^BOOL(id data){
        return ![@0 isEqualToNumber:data];
    });
    [self.children.lastObject setName:@"notZero"];
    return self;
}

-(instancetype)isMinus{
    self.is(^BOOL(id data){
        return 0 > [data doubleValue];
    });
    
    [self.children.lastObject setName:@"isMinus"];
    return self;
}

-(instancetype)notMinus{
    self.is(^BOOL(id data){
        return !(0 > [data doubleValue]);
    });
    
    [self.children.lastObject setName:@"notMinus"];
    return self;
}

-(instancetype)isPlus{
    self.is(^BOOL(id data){
        return 0 < [data doubleValue];
    });
    [self.children.lastObject setName:@"isPlus"];
    return self;
}

-(instancetype)notPlus{
    self.is(^BOOL(id data){
        return !(0 < [data doubleValue]);
    });
    [self.children.lastObject setName:@"notPlus"];
    return self;
}

-(zRuleForNSNumber *(^)(NSNumber *num))eq{
    return ^(NSNumber *num){
        self.is(^BOOL(id data){
            return [num isEqualToNumber:data];
        });
        [self.children.lastObject setName:[NSString stringWithFormat:@"equal(%@)", num]];
        return self;
    };
}


-(zRuleForNSNumber *(^)(NSNumber *))gt{
    return ^(NSNumber *num){
        self.is(^BOOL(id data){
            return [data doubleValue] > [num doubleValue];
        });
        [self.children.lastObject setName:[NSString stringWithFormat:@"gt(%@)", num]];
        return self;
    };
}

-(zRuleForNSNumber *(^)(NSNumber *))lt{
    return ^(NSNumber *num){
        self.is(^BOOL(id data){
            return [data doubleValue] < [num doubleValue];
        });
        [self.children.lastObject setName:[NSString stringWithFormat:@"lt(%@)", num]];
        return self;
    };
}

-(zRuleForNSNumber *(^)(NSNumber *min, NSNumber *max))inRange{
    return ^(NSNumber *min, NSNumber *max){
        self.is(^BOOL(id data){
            return [min doubleValue] <= [data doubleValue] && [max doubleValue] >= [data doubleValue];
        });
        [self.children.lastObject setName:[NSString stringWithFormat:@"inRange(%@, %@)", min, max]];
        return self;
    };
}

@end
