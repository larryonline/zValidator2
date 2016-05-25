//
//  zRuleWithChainingTest.m
//  zVlidator2
//
//  Created by ZhangZhenNan on 16/5/23.
//  Copyright © 2016年 zhennan.me. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "zRule.h"

@interface zRuleWithChainingTest : XCTestCase

@end

@implementation zRuleWithChainingTest

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testRuleChaining{
    
    id<zRule> rule = [zComplexRule ruleLogicAND].is(^BOOL(id data){
        return [data isKindOfClass:[NSString class]];
    }).is(^BOOL(id data){
        return [data length] > 4;
    }).is(^BOOL (id data){
        return [data length] < 6;
    });
    
    NSLog(@"\n%@", [rule debugDescription]);
    NSAssert([rule validate:@"11111"], @"should not be NO");
}

- (void)testRuleChaining2{
    
    zRule *originRule = [zRule new];
    
    zRule *rule = originRule.is(^BOOL(id data){
        return nil != data;
    });
    
    NSAssert(rule != originRule, @"after \"is\" method get called. the rule should not be same as originRule");
    
    NSAssert([rule validate:@1], @"should not be NO");
    
    rule = originRule.not(^BOOL(id data){
        return nil != data;
    });
    NSAssert(rule != originRule, @"after \"not\" method get called. the rule should not be same as originRule");
    
    NSAssert([rule validate:nil], @"should not be NO");
    
    
    originRule = [zRuleWithComparator new];
    rule = originRule.is(^BOOL(id data){
        return nil != data;
    });
    
    NSAssert(rule == originRule, @"after \"is\" get called. the rule should be same as originRule");
    NSAssert([rule validate:@1], @"should not be NO");
    
    originRule = [zRuleWithComparator new];
    rule = originRule.not(^BOOL(id data){
        return nil != data;
    });
    
    NSAssert(rule == originRule, @"after \"not\" get called. the rule should be same as originRule");
    NSAssert([rule validate:nil], @"should not be NO");
    
    
    zRule *and = [zComplexRule ruleLogicAND].is(^BOOL(id data){
        return [data isKindOfClass:[NSString class]];
    }).not(^BOOL(id data){
        return [data length] > 5;
    });
    
    NSAssert([and validate:@"111"], @"should not be NO");
    NSAssert(![and validate:@"111111"], @"should not be YES");
}

@end
