//
//  zRule.h
//  zVlidator2
//
//  Created by ZhangZhenNan on 16/5/22.
//  Copyright © 2016年 zhennan.me. All rights reserved.
//

#import <Foundation/Foundation.h>
#pragma mark - zRule
@class zComplexRule;

@interface zRule : NSObject<NSCopying>
@property (nonatomic, weak) zComplexRule * _Nullable parent;
@property (nonatomic, copy) NSString * _Nullable name;

-(BOOL)verify:(_Nullable id)data;
@end


#pragma mark - zRuleWithComparator
typedef BOOL (^zComparatorBlock)(_Nullable id data);
@interface zRuleWithComparator : zRule
@property (nonatomic, copy, readonly) zComparatorBlock _Nonnull comparator;

-(_Nonnull id)initWithComparator:(_Nonnull zComparatorBlock)comparator;
+(_Nonnull id)ruleWithComparator:(_Nonnull zComparatorBlock)comparator;
@end


#pragma mark - zComplexRule
@interface zComplexRule : zRule
@property (nonatomic, copy, readonly) NSArray<zRule *> * _Nullable children;
@property (nonatomic, assign, readonly) NSUInteger count;

-(_Nonnull id)initWithChildren:(NSArray<zRule *> * _Nullable)children;

+(_Nonnull id)ruleWithChildren:(NSArray<zRule *> * _Nullable)children;
@end

@interface zComplexRule(Mutable)
-(NSUInteger)addRule:(zRule * _Nonnull )rule;
-(NSUInteger)removeRule:(zRule * _Nonnull )rule;
-(zRule * _Nonnull )removeRuleAtIndex:(NSUInteger) index;
@end

@interface zRuleAND : zComplexRule
+(_Nonnull id)ruleWithChildRule:(zRule * _Nonnull)rule andChildRule:(zRule * _Nonnull)otherRule;
@end

@interface zRuleOR : zComplexRule
+(_Nonnull id)ruleWithChildRule:(zRule * _Nonnull)rule orChildRule:(zRule * _Nonnull)otherRule;
@end


#pragma mark - Combination
@interface zRule(Combination)
-(zRuleOR * _Nonnull )orWithRule:(zRule * _Nonnull )rule;
-(zRuleAND * _Nonnull )andWithRule:(zRule * _Nonnull )rule;
@end

#pragma mark - Chaining Support
@interface zRule(ChainingSupport)
-(zRule * _Nonnull (^ _Nonnull)(zComparatorBlock _Nonnull))is;
-(zRule * _Nonnull (^ _Nonnull)(zComparatorBlock _Nonnull))not;
@end