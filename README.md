# zValidator2
Objective-C validation toolkit with chaining syntax

---
# Features
- MultiRule validation support 
- Chaining syntax support

---
# How to use

### Basic usage
```Objective-C
zRule *rule = [zRuleWithComparator ruleWithComparator:^BOOL(id data){
  return [data isKindOfClass:[NSString class]] && [@"i am the correct string" isEqualToString:data];
}]

if([rule verify:@"random string"]){
    // we cool ;p
}else{
    // something happened.
}
```

### Chaning + Block
```Objective-C
  zRule *rule = [zRuleAND new].is(^BOOL(id data){
    return [data isKindOfClass:[NSString class]];
  }).is(^BOOL(id data){
    return [data length] > 3;
  }).is(^BOOL(id data){
    return [data length] < 5;
  });

  NSAssert([rule verify:@"abcd"], @"oh shit".);     // we cool here ;p
  NSAssert([rule verify:@"abc"], @"oh shit.");      // oh shit.
  NSAssert([rule verify:@"abcde"], @"oh shit.");    // oh shit.
```
  

---
# Installation
~~Installation with Cocoapods~~

---
# Issues
Any problems? please post issues [here](https://github.com/larryonline/zValidator2/issues).

---
# Road Map

- FoundationKit support.
- UIKit support.
- Configuration file support.
- EVEN MORE...

---
# Licenses
All source code is licensed under the [MIT License](https://raw.github.com/larryonline/zValidator2/master/LICENSE).
