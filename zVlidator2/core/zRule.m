//
//  zRule.m
//  zVlidator2
//
//  Created by ZhangZhenNan on 16/5/22.
//  Copyright © 2016年 zhennan.me. All rights reserved.
//

#import "zRule.h"

#pragma - zRule
@interface zRule()
@property (nonatomic, copy) NSString *uuid;
@end

@implementation zRule

+(NSString *)makeUUID{
    CFUUIDRef uuid_ref = CFUUIDCreate(NULL);
    CFStringRef uuid_string_ref= CFUUIDCreateString(NULL, uuid_ref);
    NSString *uuid = [NSString stringWithString:(__bridge NSString *)uuid_string_ref];
    CFRelease(uuid_ref);
    CFRelease(uuid_string_ref);
    return [uuid lowercaseString];
}

@synthesize uuid = _uuid, name = _name;

-(id)initWithUuid:(NSString *)uuid{
    if(self = [super init]){
        NSAssert(nil != uuid && ![@"" isEqualToString:uuid], @"Given UUID[%@] *CAN NOT* be empty", uuid);
        self.uuid = uuid;
    }
    return self;
}

-(id)init{
    return [self initWithUuid:[[self class] makeUUID]];
}

-(BOOL)verify:(id)data{
    [NSException raise:@"DEFAULT IMPLEMENTATION, SUBCLASS SHOULD OVERRIDE THIS METHOD." format:@"zRule is an ABSTRACT class, you should not use it directly, please extend it and override it's -(BOOL)verify:(id)data method."];
    return NO;
}

-(id)copyWithZone:(NSZone *)zone{
    return [[[self class] allocWithZone:zone] initWithUuid:self.uuid];
}

-(BOOL)isEqual:(id)object{
    return [object isKindOfClass:[self class]] && [[self uuid] isEqualToString:[object uuid]];
}

-(NSUInteger)hash{
    return [[self class] hash] ^ [[self uuid] hash];
}

-(NSString *)debugDescription{
    if([self.name isKindOfClass:[NSString class]] && 0 < [self.name length]){
        return [NSString stringWithFormat:@"[%@]", self.name];
    }else{
        return [NSString stringWithFormat:@"[%@ %p]", NSStringFromClass([self class]), (void *)self];
    }
}

@end

#pragma mark - zRuleWithComparator

@interface zRuleWithComparator()
@property (nonatomic, copy) zComparatorBlock comparator;
@end
@implementation zRuleWithComparator

@synthesize comparator = _comparator;

-(id)initWithComparator:(zComparatorBlock)comparator{
    if(self = [super init]){
        self.comparator = comparator;
    }
    return self;
}

-(BOOL)verify:(id)data{
    if(nil == self.comparator){
        [NSException raise:@"NO COMPARATOR EXIST" format:@"%@ | The rule comparator is nil, Are you sure you need this rule?", self];
    }
    return self.comparator(data);
}

-(id)copyWithZone:(NSZone *)zone{
    zRuleWithComparator *copy = [super copyWithZone:zone];
    copy.comparator = self.comparator;
    return copy;
}

+(id)ruleWithComparator:(zComparatorBlock)comparator{
    return [[[self class] alloc] initWithComparator:comparator];
}
@end

#pragma mark - zComplexRule
@interface zComplexRule()
@property (nonatomic, copy) NSArray<zRule *> *children;
@end
@implementation zComplexRule

@synthesize children = _children;

-(id)initWithChildren:(NSArray<zRule *> *)children{
    if(self = [super init]){
        if(nil != children){
            self.children = children;
        }
    }
    return self;
}

-(NSUInteger)count{
    return [self.children count];
}

-(id)copyWithZone:(NSZone *)zone{
    zComplexRule *copy = [super copyWithZone:zone];
    copy.children = self.children;
    return copy;
}

-(NSUInteger)hash{
    return [super hash] ^ [self.children hash];
}

+(id)ruleWithChildren:(NSArray<zRule *> *)children{
    return [[[self class] alloc] initWithChildren:children];
}

-(NSString *)debugDescription{
    NSMutableArray *result = [NSMutableArray new];
    NSString *prefix = @"    |- ";
    NSString *prefix2 = @"    | ";
    NSString *operator = @"    ??";
    
    if([self isKindOfClass:[zRuleAND class]]){
        operator = @"   AND";
    }else if([self isKindOfClass:[zRuleOR class]]){
        operator = @"    OR";
    }
    
    [result addObject:[super debugDescription]];
    
    NSInteger numOfChildren = [self.children count];
    if(0 < numOfChildren){
        
        for(NSInteger i = 0; i < numOfChildren; i++){
            NSString *raw = [[self.children objectAtIndex:i] debugDescription];
            NSArray *rows = [raw componentsSeparatedByString:@"\n"];
            if(i > 0){
                [result addObject:operator];
            }

            NSInteger numOfRow = [rows count];
            for(NSInteger j = 0; j < numOfRow; j++){
                NSString *row = [rows objectAtIndex:j];
                [result addObject:[NSString stringWithFormat:@"%@%@", 0 == j?prefix:prefix2, row]];
            }
        }
    }
    return [result componentsJoinedByString:@"\n"];
}

@end

@implementation zComplexRule(Mutable)
-(NSUInteger)addRule:(zRule *)rule{
    if(nil == rule){
        NSLog(@"CAN NOT ADD NIL INTO %@", self);
        return NSNotFound;
    }
    
    if(rule == self){
        [NSException raise:@"CAN NOT ADD RULE INTO IT'S OWN CHILDREN LIST" format:@"Are you sure you want add it into it's own children list?"];
        return NSNotFound;
    }
    
    if([self.children containsObject:rule]){
        NSLog(@"%@ ALREADY BEEN CHILD OF %@", rule, self);
        return [self.children indexOfObject:rule];
    }else if(nil != rule.parent){
        NSLog(@"REMOVE %@ FROM %@", rule, rule.parent);
        [rule.parent removeRule:rule];
        rule.parent = nil;
    }
    
    if(nil == self.children){
        NSLog(@"%@ CHILDREN LIST IS NIL, GONNA CREATE A NEW ONE", self);
        self.children = [NSArray arrayWithObject:rule];
    }else{
        NSLog(@"ADD %@ INTO %@", rule, self);
        self.children = [self.children arrayByAddingObject:rule];
    }
    rule.parent = self;
    
    return [self.children count] - 1;
}

-(NSUInteger)removeRule:(zRule *)rule{
    if(nil == rule){
        NSLog(@"CAN NOT REMOVE NIL FROM %@", self);
        return NSNotFound;
    }
    
    if(![self.children containsObject:rule]){
        NSLog(@"TRYING TO REMOVE RULE WHICH NOT IN CHILDREN LIST.");
        return NSNotFound;
    }
    
    NSMutableArray *mutable = [self.children mutableCopy];
    NSUInteger index = [mutable indexOfObject:rule];
    NSLog(@"REMOVE %@ FROM %@", rule, self);
    [mutable removeObject:rule];
    rule.parent = nil;
    
    self.children = [mutable copy];
    return index;
}

-(zRule *)removeRuleAtIndex:(NSUInteger)index{
    if(index == NSNotFound || [self count] <= index){
        NSLog(@"CAN NOT FOUND RULE IN %@ AT INDEX %ld", self, index);
        return nil;
    }
    
    NSMutableArray *mutable = [self.children mutableCopy];
    zRule *ret = [mutable objectAtIndex:index];
    NSLog(@"REMOVE %@ FROM %@ AT INDEX %ld", ret, self, index);
    [mutable removeObjectAtIndex:index];
    ret.parent = nil;
    
    self.children = [mutable copy];
    
    return ret;
}

@end

@implementation zRuleAND
-(BOOL)verify:(id)data{
    if(nil == self.children){
        [NSException raise:@"NO CHILDREN IN COMPLEX RULE" format:@"The children list is nil, Are you sure you need this rule?"];
    }
    BOOL ret = YES;
    for(zRule *rule in self.children){
        ret = ret && [rule verify:data];
        if(NO == ret){
            break;
        }
    }
    return ret;
}

+(id)ruleWithChildRule:(zRule *)rule andChildRule:(zRule *)otherRule{
    if(nil == rule || nil == otherRule){
        [NSException raise:@"GIVEN RULE SHOULD NOT BE NIL." format:@"The given rules should not be nil"];
    }
    
    return [[self class] ruleWithChildren:@[rule, otherRule]];
}

@end

@implementation zRuleOR
-(BOOL)verify:(id)data{
    if(nil == self.children){
        [NSException raise:@"GIVEN NO CHILDREN IN COMPLEX RULE" format:@"The children list is nil, Are you sure you need this rule?"];
    }
    
    BOOL ret = NO;
    for(zRule *rule in self.children){
        ret = ret || [rule verify:data];
        if(YES == ret){
            break;
        }
    }
    return ret;
}

+(id)ruleWithChildRule:(zRule *)rule orChildRule:(zRule *)otherRule{
    if(nil == rule || nil == otherRule){
        [NSException raise:@"RULE SHOULD NOT BE NIL." format:@"The given rules should not be nil"];
    }
    
    return [[self class] ruleWithChildren:@[rule, otherRule]];
}
@end

#pragma mark - Combination
@implementation zRule(Combination)
-(zRuleOR *)orWithRule:(zRule *)rule{
    if(nil == rule){
        [NSException raise:@"GIVEN RULE SHOULD NOT BE NIL." format:@"The given rules should not be nil"];
    }
    
    return [[zRuleOR alloc] initWithChildren:@[self, rule]];
}

-(zRuleAND *)andWithRule:(zRule *)rule{
    if(nil == rule){
        [NSException raise:@"GIVEN RULE SHOULD NOT BE NIL." format:@"The given rules should not be nil"];
    }
    
    return [[zRuleAND alloc] initWithChildren:@[self, rule]];
}
@end

@implementation zRuleAND(Combination)

-(zRule *)andWithRule:(zRule *)rule{
    if(nil == rule){
        [NSException raise:@"GIVEN RULE SHOULD NOT BE NIL." format:@"The given rules should not be nil"];
    }
    
    [self addRule:rule];
    return self;
}

@end

@implementation zRuleOR(Combination)

-(zRule *)orWithRule:(zRule *)rule{
    if(nil == rule){
        [NSException raise:@"GIVEN RULE SHOULD NOT BE NIL." format:@"The given rules should not be nil"];
    }
    [self addRule:rule];
    return self;
}

@end

#pragma mark - Chaining Support
@implementation zRule(ChainingSupport)
-(zRule *(^)(zComparatorBlock))is{
    return ^(zComparatorBlock block){
        return [zRuleWithComparator ruleWithComparator:block];
    };
}

-(zRule *(^)(zComparatorBlock))not{
    return ^(zComparatorBlock block){
        return [zRuleWithComparator ruleWithComparator:^BOOL(id  _Nullable data) {
            return !block(data);
        }];
    };
}
@end

@implementation zRuleWithComparator(ChainingSupport)
-(zRuleWithComparator *(^)(zComparatorBlock))is{
    return ^(zComparatorBlock block){
        self.comparator = block;
        return self;
    };
}

-(zRuleWithComparator *(^)(zComparatorBlock))not{
    return ^(zComparatorBlock block){
        self.comparator = ^BOOL(id data){
            return !block(data);
        };
        return self;
    };
}

@end

@implementation zComplexRule(ChainingSupport)
-(zComplexRule *(^)(zComparatorBlock))is{
    return ^(zComparatorBlock block){
        [self addRule:[zRuleWithComparator ruleWithComparator:block]];
        return self;
    };
}

-(zComplexRule *(^)(zComparatorBlock))not{
    return ^(zComparatorBlock block){
        [self addRule:[zRuleWithComparator ruleWithComparator:^BOOL(id  _Nullable data) {
            return !block(data);
        }]];
        return self;
    };
}

@end