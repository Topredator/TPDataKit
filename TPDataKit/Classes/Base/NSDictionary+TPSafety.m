//
//  NSDictionary+TPSafety.m
//  TPKit
//
//  Created by Topredator on 2019/3/2.
//

#import "NSDictionary+TPSafety.h"

@implementation NSDictionary (TPSafety)
- (id)tpObjectForKey:(id)key validatedByClass:(Class)objClass {
    id object = [self objectForKey:key];
    if (object && [object isKindOfClass:objClass]) {
        return object;
    }
    return nil;
}

- (NSString *)tpStringObjectForKey:(id)key {
    return [self tpObjectForKey:key validatedByClass:NSString.class];
}
- (NSNumber *)tpNumberObjectForKey:(id)key {
    return [self tpObjectForKey:key validatedByClass:NSNumber.class];
}
- (NSValue *)tpValueObjectForKey:(id)key {
    return [self tpObjectForKey:key validatedByClass:NSValue.class];
}
- (NSArray *)tpArrayObjectForKey:(id)key {
    return [self tpObjectForKey:key validatedByClass:NSArray.class];
}
- (NSDictionary *)tpDictionaryObjectForKey:(id)key {
    return [self tpObjectForKey:key validatedByClass:NSDictionary.class];
}
- (BOOL)tpBoolObjectForKey:(id)key {
    id obj = [self objectForKey:key];
    if (obj && ([obj isKindOfClass:NSNumber.class] || [obj isKindOfClass:NSString.class])) {
        return [obj boolValue];
    }
    return NO;
}
- (double)tpDoubleObjectForKey:(id)key {
    id obj = [self objectForKey:key];
    if (obj && ([obj isKindOfClass:NSNumber.class] || [obj isKindOfClass:NSString.class])) {
        return [obj doubleValue];
    }
    return 0;
}
- (NSInteger)tpIntegerObjectForKey:(id)key {
    id obj = [self objectForKey:key];
    if (obj && ([obj isKindOfClass:NSNumber.class] || [obj isKindOfClass:NSString.class])) {
        return [obj integerValue];
    }
    return 0;
}
@end

@implementation NSMutableDictionary (TPSafety)
- (void)tpSetObject:(id)object forKey:(id)key {
    if (object && key) {
        [self setObject:object forKey:key];
    }
}
- (void)tpRemoveObjectForKey:(id)key {
    if (key) {
        [self removeObjectForKey:key];
    }
}

@end
