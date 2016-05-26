//
//  NSNumber+zValidatorTest.m
//  zVlidator2
//
//  Created by ZhangZhenNan on 16/5/25.
//  Copyright © 2016年 zhennan.me. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "NSNumber+zValidator.h"

@interface NSNumber_zValidatorTest : XCTestCase

@end

@implementation NSNumber_zValidatorTest

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}


- (void)testRuleForNSNumber{
    zRuleForNSNumber *ruleAND = [NSNumber zvAND].isZero;
    zRuleForNSNumber *ruleOR = [NSNumber zvOR].isZero;
    
    
    NSAssert(![ruleAND validate:@"1"], @"return NO, because the given data is not instance of NSNumber");
    NSAssert(![ruleOR validate:@"1"], @"return NO, because the given data is not instance of NSNUmber");
}

- (void)testRuleForNSNumber_isZero{
    zRuleForNSNumber *rule = [NSNumber zvAND].isZero;
    NSAssert([rule validate:@0], @"should be YES");
    NSAssert(![rule validate:@0.00000000000000000000000000000000001], @"should be NO");
    NSAssert(![rule validate:@-0.0000000000000000000000000000000001], @"should be NO");
    
    rule = [NSNumber zvAND].notZero;
    
    NSAssert(![rule validate:@0], @"should be NO");
    NSAssert([rule validate:@0.00000000000000000000000000000000001], @"should be YES");
    NSAssert([rule validate:@-0.0000000000000000000000000000000001], @"should be YES");
}

- (void)testRuleForNSNumber_isPlus{
    zRuleForNSNumber *rule = [NSNumber zvAND].isPlus;
    NSAssert(![rule validate:@0], @"should be NO");
    NSAssert([rule validate:@0.00000000000000000000000000000000001], @"should be YES");
    NSAssert(![rule validate:@-0.0000000000000000000000000000000001], @"should be NO");
    
    rule = [NSNumber zvAND].notPlus;
    NSAssert([rule validate:@0], @"should be YES");
    NSAssert(![rule validate:@0.00000000000000000000000000000000001], @"should be NO");
    NSAssert([rule validate:@-0.0000000000000000000000000000000001], @"should be YES");
}

-(void)testRuleForNSNumber_isMinus{
    zRuleForNSNumber *rule = [NSNumber zvAND].isMinus;
    NSAssert(![rule validate:@0], @"should be NO");
    NSAssert(![rule validate:@0.00000000000000000000000000000000001], @"should be NO");
    NSAssert([rule validate:@-0.0000000000000000000000000000000001], @"should be YES");
    
    rule = [NSNumber zvAND].notMinus;
    NSAssert([rule validate:@0], @"should be YES");
    NSAssert([rule validate:@0.00000000000000000000000000000000001], @"should be YES");
    NSAssert(![rule validate:@-0.0000000000000000000000000000000001], @"should be NO");
}


@end
