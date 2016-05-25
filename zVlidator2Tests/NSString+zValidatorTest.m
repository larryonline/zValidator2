//
//  NSString+zValidatorTest.m
//  zVlidator2
//
//  Created by ZhangZhenNan on 16/5/24.
//  Copyright © 2016年 zhennan.me. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "NSString+zValidator.h"

@interface NSString_zValidatorTest : XCTestCase

@end

@implementation NSString_zValidatorTest

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

-(void) testRuleForNSString{
    
    zRuleForNSString *ruleAND = [NSString zvAND].notEmpty;
    zRuleForNSString *ruleOR = [NSString zvOR].notEmpty;
    
    @try{
        [ruleAND validate:@1];
        [NSException raise:@"UNACCEPTABLE" format:@"CODE SHOULD NOT GO HERE, BECAUSE VALIDATE WITH NIL COMPARATOR WILL RAISE AN EXCEPTION"];
    } @catch (NSException *exception) {
        NSAssert(![@"UNACCEPTABLE" isEqualToString:[exception name]], @"%@", exception);
    }
    
    @try{
        [ruleOR validate:@1];
        [NSException raise:@"UNACCEPTABLE" format:@"CODE SHOULD NOT GO HERE, BECAUSE VALIDATE WITH NIL COMPARATOR WILL RAISE AN EXCEPTION"];
    } @catch (NSException *exception) {
        NSAssert(![@"UNACCEPTABLE" isEqualToString:[exception name]], @"%@", exception);
    }
    
    
}

-(void) testNSStringWithRule{
    
    zRuleForNSString *rule  = [NSString zvAND];
    rule.contains(@"i").contains(@"am").contains(@"validator");
    
    NSAssert([rule validate:@"hello, i am validator. nice to meet you. : )"], @"should be YES");
    NSAssert(![rule validate:@"i'm larry."], @"should be NO");
    NSAssert(![rule validate:@"i am test string."], @"should be NO");
    
    rule = [NSString zvOR];
    rule.contains(@"i").contains(@"am").contains(@"validator");
    
    NSAssert([rule validate:@"i'm developer"], @"should be YES.");
    NSAssert([rule validate:@"AMD is a CPU brand."], @"should be YES.");
    NSAssert([rule validate:@"zValidator is a cool lib"], @"should be YES.");
}

-(void) testRuleForNSString_Empty{
    zRuleForNSString *rule = [NSString zvAND].isEmpty;
    NSAssert([rule validate:@""], @"should be YES");
    NSAssert(![rule validate:@"test"], @"should be NO");
    
    rule = [NSString zvAND].notEmpty;
    NSAssert([rule validate:@"test"], @"should be YES");
    NSAssert(![rule validate:@""], @"should be NO");
}

-(void) testRuleForNSString_contains{
    zRuleForNSString *rule = [NSString zvAND].contains(@"i am");
    NSAssert([rule validate:@"i am zValidator"], @"should be YES");
    NSAssert(![rule validate:@"iOS"], @"should be NO");
    
    rule = [NSString zvAND].notContains(@"i am");
    NSAssert(![rule validate:@"i am zValidator"], @"should be NO");
    NSAssert([rule validate:@"iOS"], @"should be YES");
}

-(void)testRuleForNSString_match{
    zRuleForNSString *rule = [NSString zvAND].match(@"[a-z]{3}\\.");
    NSAssert([rule validate:@"abc."], @"should be YES");
    NSAssert([rule validate:@"xyz."], @"should be YES");
    NSAssert(![rule validate:@"XYZ."], @"should be NO");
    NSAssert(![rule validate:@"123."], @"should be NO");
    NSAssert(![rule validate:@"@@@."], @"should be NO");
    
    rule = [NSString zvAND].notMatch(@"[a-z]{3}\\.");
    NSAssert(![rule validate:@"abc."], @"should be NO");
    NSAssert(![rule validate:@"xyz."], @"should be NO");
    NSAssert([rule validate:@"XYZ."], @"should be YES");
    NSAssert([rule validate:@"123."], @"should be YES");
    NSAssert([rule validate:@"@@@."], @"should be YES");
    
    
}

-(void)testRuleForNSString_inRange{
    zRuleForNSString *rule = [NSString zvAND].inRange(1, 2);
    NSAssert(![rule validate:@""], @"should be NO");
    NSAssert([rule validate:@"1"], @"should be YES");
    NSAssert([rule validate:@"12"], @"should be YES");
    NSAssert(![rule validate:@"123"], @"should be NO");
    
    rule = [NSString zvAND].notInRange(3,4);
    NSAssert([rule validate:@""], @"should be YES");
    NSAssert([rule validate:@"1"], @"should be YES");
    NSAssert([rule validate:@"12"], @"should be YES");
    NSAssert(![rule validate:@"123"], @"should be NO");
    NSAssert(![rule validate:@"1234"], @"should be NO");
    NSAssert([rule validate:@"12345"], @"should be YES");
    
}

@end
