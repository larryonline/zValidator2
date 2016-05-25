//
//  zRule.h
//  zVlidator2
//
//  Created by ZhangZhenNan on 16/5/22.
//  Copyright © 2016年 zhennan.me. All rights reserved.
//

#import <Foundation/Foundation.h>

#pragma mark - protocols
@protocol zRule, zComplexRule, zRuleWithChainingSupport;

// Basic Validation Support
@protocol zRule <NSObject, NSCopying, zRuleWithChainingSupport>
@property (nonatomic, copy) NSString * _Nullable name;

@property (nonatomic, weak, readonly) id<zComplexRule> _Nullable root;
@property (nonatomic, weak) id<zComplexRule> _Nullable parent;

-(BOOL)validate:(id _Nullable)data;
@end

// Multi-Rule Validation Support
@protocol zComplexRuleOperation <NSObject, NSCopying>
@property (nonatomic, copy, readonly) NSString * _Nonnull name;
-(BOOL)validate:(id _Nonnull)data withRules:(NSArray<id<zRule>> * _Nonnull)rules;
@end

@protocol zComplexRule <zRule>
@property (nonatomic, copy) id<zComplexRuleOperation> _Nonnull operation;

@property (nonatomic, copy, readonly) NSArray<id<zRule>> * _Nullable children;
@property (nonatomic, assign, readonly) NSUInteger count;


-(NSUInteger)addRule:(id<zRule> _Nonnull)rule;
-(NSUInteger)removeRule:(id<zRule> _Nonnull)rule;
-(id<zRule> _Nullable)removeRuleAtIndex:(NSUInteger)index;

+(id _Nonnull)ruleWithChildren:(NSArray<id<zRule>> * _Nonnull)children operation:(id<zComplexRuleOperation> _Nonnull)operation;

+(instancetype _Nonnull)ruleLogicAND;
+(instancetype _Nonnull)ruleLogicANDWithChildren:(NSArray<id<zRule>> * _Nonnull)children;

+(instancetype _Nonnull)ruleLogicOR;
+(instancetype _Nonnull)ruleLogicORWithChildren:(NSArray<id<zRule>> * _Nonnull)children;
@end


// Chaining Syntax Support
typedef BOOL (^zRuleComparatorBlock)(_Nullable id data);
@protocol zRuleWithChainingSupport <NSObject>
-(id<zRule> _Nonnull(^ _Nonnull)(zRuleComparatorBlock _Nonnull))is;
-(id<zRule> _Nonnull(^ _Nonnull)(zRuleComparatorBlock _Nonnull))not;
@end


#pragma mark - zRule
@interface zRule : NSObject<zRule>
@end

#pragma mark - zRuleWithComparator
@interface zRuleWithComparator : zRule
@property (nonatomic, copy, readonly) zRuleComparatorBlock _Nonnull comparator;
-(_Nonnull id)initWithComparator:(zRuleComparatorBlock _Nonnull)comparator;
+(_Nonnull id)ruleWithComparator:(zRuleComparatorBlock _Nonnull)comparator;
@end

#pragma mark - zComplexRule
@interface zComplexRule : zRule<zComplexRule>
-(_Nonnull id)initWithChildren:(NSArray<id<zRule>> * _Nullable)children operation:(id<zComplexRuleOperation> _Nonnull)operation;
@end

