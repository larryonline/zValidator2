//
//  zRule.m
//  zVlidator2
//
//  Created by ZhangZhenNan on 16/5/22.
//  Copyright © 2016年 zhennan.me. All rights reserved.
//

#import "zRule.h"

// uuid for each rule.
static NSString *makeUUID(){
    CFUUIDRef uuid_ref = CFUUIDCreate(NULL);
    CFStringRef uuid_string_ref= CFUUIDCreateString(NULL, uuid_ref);
    NSString *uuid = [NSString stringWithString:(__bridge NSString *)uuid_string_ref];
    CFRelease(uuid_ref);
    CFRelease(uuid_string_ref);
    return [uuid lowercaseString];
}

#pragma - zRule
@interface zRule()
@property (nonatomic, copy) NSString *uuid;
@end

@implementation zRule

@synthesize uuid = _uuid, name = _name, parent = _parent;

-(id)initWithUuid:(NSString *)uuid{
    if(self = [super init]){
        NSAssert(nil != uuid && ![@"" isEqualToString:uuid], @"Given UUID[%@] *CAN NOT* be EMPTY", uuid);
        self.uuid = uuid;
    }
    return self;
}

-(id)init{
    return [self initWithUuid:makeUUID()];
}

-(id<zComplexRule>)root{
    return nil == self.parent? nil : self.parent.root;
}

-(BOOL)validate:(id)data{
    [NSException raise:@"DEFAULT IMPLEMENTATION, SUBCLASS SHOULD OVERRIDE THIS METHOD." format:@"zRule is an ABSTRACT class, you can not use it directly, please extend it and override then -(BOOL)validate:(id)data method."];
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

// Chaining Syntax Support

-(id<zRule> (^)(zRuleComparatorBlock))is{
    return ^(zRuleComparatorBlock block){
        return [zRuleWithComparator ruleWithComparator:block];
    };
}

-(id<zRule> (^)(zRuleComparatorBlock))not{
    return ^(zRuleComparatorBlock block){
        return [zRuleWithComparator ruleWithComparator:^BOOL(id  _Nullable data) {
            return !block(data);
        }];
    };
}

// Debug Support

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
@property (nonatomic, copy) zRuleComparatorBlock comparator;
@end
@implementation zRuleWithComparator

@synthesize comparator = _comparator;

-(id)initWithComparator:(zRuleComparatorBlock)comparator{
    if(self = [super init]){
        self.comparator = comparator;
    }
    return self;
}

-(BOOL)validate:(id)data{
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

// Chaining Support
-(id<zRule> (^)(zRuleComparatorBlock))is{
    return ^(zRuleComparatorBlock block){
        self.comparator = block;
        return self;
    };
}

-(id<zRule> (^)(zRuleComparatorBlock))not{
    return ^(zRuleComparatorBlock block){
        self.comparator = ^BOOL(id data){
            return !block(data);
        };
        return self;
    };
}


+(id)ruleWithComparator:(zRuleComparatorBlock)comparator{
    return [[[self class] alloc] initWithComparator:comparator];
}

@end

#pragma mark - zComplexRuleOperations
@interface zComplexRuleOperationLogicAND:NSObject<zComplexRuleOperation>
@end
@implementation zComplexRuleOperationLogicAND
-(NSString *)name{
    return @"AND";
}
-(BOOL)validate:(id)data withRules:(NSArray<id<zRule>> *)rules{
    BOOL ret = YES;
    for(id<zRule> rule in rules){
        ret = ret && [rule validate:data];
        if(NO == ret){
            break;
        }
    }
    return ret;
}
-(id)copyWithZone:(NSZone *)zone{
    return [[[self class] allocWithZone:zone] init];
}
@end

@interface zComplexRuleOperationLogicOR : NSObject<zComplexRuleOperation>
@end
@implementation zComplexRuleOperationLogicOR
-(NSString *)name{
    return @"OR";
}
-(BOOL)validate:(id)data withRules:(NSArray<id<zRule>> *)rules{
    BOOL ret = NO;
    for(zRule *rule in rules){
        ret = ret || [rule validate:data];
        if(YES == ret){
            break;
        }
    }
    return ret;
}

-(id)copyWithZone:(NSZone *)zone{
    return [[[self class] allocWithZone:zone] init];
}
@end

#pragma mark - zComplexRule
@interface zComplexRule()
@property (nonatomic, copy) NSArray<zRule *> *children;
@end
@implementation zComplexRule

@synthesize children = _children, operation = _operation;

-(id)initWithChildren:(NSArray<zRule *> *)children operation:(id<zComplexRuleOperation>)operation{
    if(self = [super init]){
        if(nil != children){
            self.children = children;
        }
        self.operation = operation;
    }
    return self;
}

-(NSUInteger)count{
    return [self.children count];
}

-(id<zComplexRule>)root{
    return nil != self.parent? self.parent.root : 0 < self.count? self : nil;
}

-(id)copyWithZone:(NSZone *)zone{
    zComplexRule *copy = [super copyWithZone:zone];
    copy.operation = self.operation;
    copy.children = self.children;
    return copy;
}

-(NSUInteger)hash{
    return [super hash] ^ [self.children hash];
}

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

-(BOOL)validate:(id)data{
    if(nil == self.children){
        [NSException raise:@"NO CHILDREN IN COMPLEX RULE" format:@"The children list is nil, Are you sure you need this rule?"];
    }
    
    if(nil == self.operation){
        [NSException raise:@"NO OPERATION BLOCK IN COMPLEX RULE" format:@"The operation block is nil, Are you sure you need this rule?"];
    }
    
    return [self.operation validate:data withRules:self.children];
}


-(NSString *)debugDescription{
    NSMutableArray *result = [NSMutableArray new];
    NSString *prefix = @"    |- ";
    NSString *prefix2 = @"    | ";
    NSString *operator = [NSString stringWithFormat:@"    %@", self.operation.name];
    
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

-(id<zRule> (^)(zRuleComparatorBlock))is{
    return ^(zRuleComparatorBlock block){
        [self addRule:[zRuleWithComparator ruleWithComparator:block]];
        return self;
    };
}

-(id<zRule> (^)(zRuleComparatorBlock))not{
    return ^(zRuleComparatorBlock block){
        [self addRule:[zRuleWithComparator ruleWithComparator:^BOOL(id  _Nullable data) {
            return !block(data);
        }]];
        return self;
    };
}

+(instancetype)ruleWithChildren:(NSArray<id<zRule>> *)children operation:(id<zComplexRuleOperation>)operation{
    id<zComplexRule> rule = [[[self class] alloc] initWithChildren:children operation:operation];
    return rule;
}


+(instancetype)ruleLogicANDWithChildren:(NSArray<id<zRule>> *)children{
    id result = [[self class] ruleWithChildren:children operation:[zComplexRuleOperationLogicAND new]];
    return result;
}
+(instancetype)ruleLogicAND{
    return [[self class] ruleLogicANDWithChildren:@[]];
}

+(instancetype)ruleLogicORWithChildren:(NSArray<id<zRule>> *)children{
    id result = [[self class] ruleWithChildren:children operation:[zComplexRuleOperationLogicOR new]];
    return result;
}

+(instancetype)ruleLogicOR{
    return [[self class] ruleLogicORWithChildren:@[]];
}
@end