//
//  zRuleTest.m
//  zVlidator2
//
//  Created by ZhangZhenNan on 16/5/23.
//  Copyright © 2016年 zhennan.me. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "zRule.h"

@interface zRuleTest : XCTestCase

@end

@implementation zRuleTest

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testRule{
    zRule *rule = [zRule new];
    
    @try {
        [rule validate:nil];
        [NSException raise:@"UNACCEPTABLE" format:@"CODE SHOULD NOT GO HERE, BECAUSE VALIDATE WITH NIL COMPARATOR WILL RAISE AN EXCEPTION"];
    } @catch (NSException *exception) {
        NSAssert(![@"UNACCEPTABLE" isEqualToString:[exception name]], @"%@", exception);
    }
    
    
    zRuleWithComparator *ruleWithComparator = [zRuleWithComparator new];
    zComplexRule *complexRule = [zComplexRule new];
    
    
    // test isEqual implementation
    NSArray *list = @[rule, ruleWithComparator, complexRule];
    id tester = [rule copy];
    NSAssert(0 == [list indexOfObject:tester], @"CAN NOT FOUND COPY IN RULE LIST");
    tester = [ruleWithComparator copy];
    NSAssert(1 == [list indexOfObject:tester], @"CAN NOT FOUND COPY IN RULE LIST");
    tester = [complexRule copy];
    NSAssert(2 == [list indexOfObject:tester], @"CAN NOT FOUND COPY IN RULE LIST");
    
    
    // test hash implementation
    NSDictionary *map = @{
        rule : @1,
        ruleWithComparator: @2,
        complexRule: @3,
    };
    tester = [rule copy];
    NSAssert(1 == [[map objectForKey:tester] integerValue], @"CAN NOT FOUND COPY IN RULE DICTIONARY");
    tester = [ruleWithComparator copy];
    NSAssert(2 == [[map objectForKey:tester] integerValue], @"CAN NOT FOUND COPY IN RULE DICTIONARY");
    tester = [complexRule copy];
    NSAssert(3 == [[map objectForKey:tester] integerValue], @"CAN NOT FOUND COPY IN RULE DICTIONARY");
}


- (void)testRuleWithComparator{
    zRuleWithComparator *rule = [zRuleWithComparator ruleWithComparator:^BOOL(id  _Nullable data) {
        return nil != data;
    }];
    
    NSAssert([rule validate:@1], @"should not be NO");
    NSAssert(![rule validate:nil], @"should not be YES");
    
    
    rule = [[zRuleWithComparator alloc] initWithComparator:nil];
    @try {
        [rule validate:@2];
        [NSException raise:@"UNACCEPTABLE" format:@"CODE SHOULD NOT GO HERE, BECAUSE VALIDATE WITH NIL COMPARATOR WILL RAISE AN EXCEPTION"];
    } @catch (NSException *exception) {
        NSAssert(![@"UNACCEPTABLE" isEqualToString:[exception name]], @"%@", exception);
    }
}

- (void)testComplexRule{
    NSArray *rules = @[[zRule new], [zRuleWithComparator new]];
    
    zComplexRule *rule = [zComplexRule ruleWithChildren:rules operation:nil];
    NSAssert(0 < [rule count], @"%@ Children should not be empty", rule);
    
    @try {
        [rule validate:nil];
        [NSException raise:@"UNACCEPTABLE" format:@"CODE SHOULD NOT GO HERE, BECAUSE VALIDATE WITH NIL COMPARATOR WILL RAISE AN EXCEPTION"];
    } @catch (NSException *exception) {
        NSAssert(![@"UNACCEPTABLE" isEqualToString:[exception name]], @"%@", exception);
    }
    
    rule = [zComplexRule ruleLogicANDWithChildren:rules];
    @try {
        [rule addRule:rule];
        [NSException raise:@"UNACCEPTABLE" format:@"CODE SHOULD NOT GO HERE, BECAUSE VALIDATE WITH NIL COMPARATOR WILL RAISE AN EXCEPTION"];
    } @catch (NSException *exception) {
        NSAssert(![@"UNACCEPTABLE" isEqualToString:[exception name]], @"%@", exception);
    }
    
    NSAssert(NSNotFound == [rule addRule:nil], @"add nil will get NSNotFound");
    NSAssert(NSNotFound == [rule removeRule:nil], @"remove nil will get NSNotFound");
    NSAssert(NSNotFound == [rule removeRule:rule], @"remove child which not in children list will get NSNotFound.");
    NSAssert(nil == [rule removeRuleAtIndex:NSNotFound], @"remove NSNotFound will get nil");
    NSAssert(nil == [rule removeRuleAtIndex:[rule count]], @"remove rule at index which bigger or equal than [rule count], will get nil");
    
    
    rule = [zComplexRule ruleLogicANDWithChildren:nil];
    
    zComplexRule *otherRule = [zComplexRule ruleLogicORWithChildren:@[]];
    zRule *childAlreadyHaveParent = [zRule new];
    [otherRule addRule:childAlreadyHaveParent];
    NSAssert(childAlreadyHaveParent.parent == otherRule, @"once the child have added into the parent rule, the child.parent should equal parent rule");
    
    [rule addRule:childAlreadyHaveParent];
    NSAssert(childAlreadyHaveParent.parent = rule, @"once the child have been added into another parent rule, the child.parent should be the latest complex rule it added.");
    
    
    zRule *child = [zRuleWithComparator ruleWithComparator:^BOOL(id  _Nullable data) {
        return NO;
    }];
    
    
    NSUInteger actual = [rule addRule:child];
    NSAssert(actual == [rule addRule:child], @"add the same child more than 1 time, nothing should happened.");
    
    NSUInteger expect = [rule.children indexOfObject:child];
    NSAssert(actual == expect, @"expect child index is %ld, but %ld", expect, actual);
    
    
    expect = [rule.children indexOfObject:child];
    actual = [rule removeRule:child];
    NSAssert(actual == expect, @"expect child index is %ld, but %ld", expect, actual);
    
    NSUInteger index = [rule addRule:child];
    id removed = [rule removeRuleAtIndex:index];
    NSAssert(removed == child, @"expect removed child %@, but actually it's %@", removed, child);
    
    
    
    zRule *isNSString = [zRuleWithComparator ruleWithComparator:^BOOL(id  _Nullable data) {
        return [data isKindOfClass:[NSString class]];
    }];
    
    zRule *isEqualInteger111 = [zRuleWithComparator ruleWithComparator:^BOOL(id  _Nullable data) {
        return [data integerValue] == 111;
    }];
    
    // test LOGIC AND
    id<zRule> and = [zComplexRule ruleLogicANDWithChildren:nil];
    @try {
        [and validate:@111];
        [NSException raise:@"UNACCEPTABLE" format:@"CODE SHOULD NOT GO HERE, BECAUSE VALIDATE WITH NIL COMPARATOR WILL RAISE AN EXCEPTION"];
    } @catch (NSException *exception) {
        NSAssert(![@"UNACCEPTABLE" isEqualToString:[exception name]], @"%@", exception);
    }
    and = [zComplexRule ruleLogicANDWithChildren:@[isNSString,isEqualInteger111]];
    NSAssert([and validate:@"111"], @"should be yes");
    NSAssert(![and validate:@111], @"should be no");
    
    
    // test LOGIC OR
    id<zRule> or = [zComplexRule ruleLogicORWithChildren:nil];
    @try {
        [or validate:@111];
        [NSException raise:@"UNACCEPTABLE" format:@"CODE SHOULD NOT GO HERE, BECAUSE VALIDATE WITH NIL COMPARATOR WILL RAISE AN EXCEPTION"];
    } @catch (NSException *exception) {
        NSAssert(![@"UNACCEPTABLE" isEqualToString:[exception name]], @"%@", exception);
    }
    or = [zComplexRule ruleLogicORWithChildren:@[isNSString,isEqualInteger111]];
    NSAssert([or validate:@"111"], @"should be yes");
    NSAssert([or validate:@111], @"should be yes");
    NSAssert(![or validate:@222], @"should be no");
}

-(void)testRuleConstructionWithNames{
    zComplexRule *root = [zComplexRule ruleLogicOR];
    
    zRule *rule = [zRule new];
    rule.name = @"isNil";
    [root addRule:rule];
    
    zComplexRule *ruleAND = [zComplexRule ruleLogicAND];
    
    rule = [zRule new];
    rule.name = @"isNSString";
    [ruleAND addRule:rule];
    
    rule = [zRule new];
    rule.name = @"lengthGreaterThan 4";
    [ruleAND addRule:rule];
    
    rule = [zRule new];
    rule.name = @"lengthLessThan 6";
    [ruleAND addRule:rule];
    
    [root addRule:ruleAND];
    
    
    NSAssert(rule.root == root, @"root chain is broken");
    NSAssert(ruleAND.root == root, @"root chain is broken");
    
    NSLog(@"\n%@", [root debugDescription]);
}

@end
