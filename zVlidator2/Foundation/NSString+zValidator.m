//
//  NSString+zValidator.m
//  zVlidator2
//
//  Created by ZhangZhenNan on 16/5/24.
//  Copyright © 2016年 zhennan.me. All rights reserved.
//

#import "NSString+zValidator.h"

@implementation NSString(zValidator)
+(zRuleForNSString *)zvOR{
    return [zRuleForNSString ruleLogicOR];
}

+(zRuleForNSString *)zvAND{
    return [zRuleForNSString ruleLogicAND];
}
@end

@implementation zRuleForNSString

-(BOOL)validate:(id)data{
    if(![data isKindOfClass:[NSString class]]){
        [NSException raise:@"INAVAILABLE GIVEN DATA" format:@"data[%@] should be member of NSString class", data];
    }
    
    return [super validate:data];
}

-(instancetype)isEmpty{
    self.is(^BOOL(id data){
        return 0 == [data length];
    });
    
    [self.children.lastObject setName:@"isEmpty"];
    return self;
}

-(instancetype)notEmpty{
    self.is(^BOOL(id data){
        return 0 < [data length];
    });
    [self.children.lastObject setName:@"notEmpty"];
    return self;
}

-(zRuleForNSString *(^)(NSInteger min, NSInteger max))inRange{
    return ^(NSInteger min, NSInteger max){
        self.is(^BOOL(id data){
            return min <= [data length] && max >= [data length];
        });
        
        [self.children.lastObject setName:[NSString stringWithFormat:@"inRange(%ld, %ld)", min, max]];
        return self;
    };
}

-(zRuleForNSString *(^)(NSInteger min, NSInteger max))notInRange{
    return ^(NSInteger min, NSInteger max){
        self.is(^BOOL(id data){
            return !(min <= [data length] && max >= [data length]);
        });
        [self.children.lastObject setName:[NSString stringWithFormat:@"notInRange(%ld, %ld)", min, max]];
        return self;
    };
}

-(zRuleForNSString *(^)(NSString *content))contains{
    return ^(NSString *content){
        self.is(^BOOL(id data){
            return [data containsString:content];
        });
        [self.children.lastObject setName:[NSString stringWithFormat:@"contains(%@)", content]];
        return self;
    };
}

-(zRuleForNSString *(^)(NSString *content))notContains{
    return ^(NSString *content){
        self.is(^BOOL(id data){
            return ![data containsString:content];
        });
        [self.children.lastObject setName:[NSString stringWithFormat:@"notContains(%@)", content]];
        return self;
    };
}

-(zRuleForNSString *(^)(NSString *format))predicate{
    return ^(NSString *format){
        self.is(^BOOL(id data){
            NSPredicate *pred = [NSPredicate predicateWithFormat:format];
            return [pred evaluateWithObject:data];
        });
        [self.children.lastObject setName:[NSString stringWithFormat:@"predicate(%@)", format]];
        return self;
    };
}

-(zRuleForNSString *(^)(NSString *format))notPredicate{
    return ^(NSString *format){
        self.is(^BOOL(id data){
            NSPredicate *pred = [NSPredicate predicateWithFormat:format];
            return ![pred evaluateWithObject:data];
        });
        
        [self.children.lastObject setName:[NSString stringWithFormat:@"notPredicate(%@)", format]];
        return self;
    };
}

-(zRuleForNSString *(^)(NSString *regexp))match{
    return ^(NSString *regexp){
        self.predicate([NSString stringWithFormat:@"SELF MATCHES '%@'", regexp]);
        return self;
        
    };
}

-(zRuleForNSString *(^)(NSString *regexp))notMatch{
    return ^(NSString *regexp){
         return self.notPredicate([NSString stringWithFormat:@"SELF MATCHES '%@'", regexp]);
    };
}

@end