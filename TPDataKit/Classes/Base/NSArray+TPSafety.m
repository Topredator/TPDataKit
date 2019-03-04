//
//  NSArray+TPSafety.m
//  TPKit
//
//  Created by Topredator on 2019/3/2.
//

#import "NSArray+TPSafety.h"

@implementation NSArray (TPSafety)
- (id)tpObjectAtIndex:(NSUInteger)index {
    if (self.count <= index) {
        return nil;
    }
    return [self objectAtIndex:index];
}
- (NSArray *)tpArrayByAddingObjectsFromArray:(NSArray *)otherArray {
    NSArray *array;
    if (otherArray) {
        array = [self arrayByAddingObjectsFromArray:otherArray];
    }
    return array;
}
/// 创建数组
+ (instancetype)createSafetyArrayWithObject:(id)anObject {
    if (anObject) {
        return [self arrayWithObject:anObject];
    }
    return [self array];
}
@end

@implementation NSMutableArray (TPSafety)
/// add
- (BOOL)tpAddObject:(id)object {
    if (object) {
        [self addObject:object];
        return YES;
    }
    return NO;
}
- (BOOL)tpAddObjectsFromArray:(NSArray *)otherArray {
    if (!otherArray) return NO;
    [self addObjectsFromArray:otherArray];
    return YES;
}
- (BOOL)tpInsertObject:(id)object atIndex:(NSUInteger)index {
    if (!object) return NO;
    if (self.count <= index) {
        [self addObject:object];
    } else {
        [self insertObject:object atIndex:index];
    }
    return YES;
}
/// remove
- (BOOL)tpRemoveObjectAtIndex:(NSUInteger)index {
    if (self.count <= index) return NO;
    [self removeObjectAtIndex:index];
    return YES;
}
- (BOOL)tpRemoveObject:(id)object {
    if (object && [self containsObject:object]) {
        [self removeObject:object];
        return YES;
    }
    return NO;
}
/// 移除大于等于某个索引的所有对象
- (BOOL)tpRemoveObjectsAfterIndex:(NSUInteger)index {
    NSUInteger count = self.count;
    if (index >= count) return NO;
    NSRange range = NSMakeRange(index, count - index);
    [self removeObjectsInRange:range];
    return YES;
}
/// 移除小于等于某个索引的所有对象
- (BOOL)tpRemoveObjectsBeforeIndex:(NSUInteger)index {
    NSUInteger count = self.count;
    if (index >= count) return NO;
    NSRange range = NSMakeRange(0, index + 1);
    [self removeObjectsInRange:range];
    return YES;
}
- (BOOL)tpRemoveObjectsInRange:(NSRange)range {
    if (range.location + range.length > self.count) return NO;
    [self removeObjectsInRange:range];
    return YES;
}
- (BOOL)tpRemoveObjectsAtIndexes:(NSIndexSet *)indexes {
    if (indexes && indexes.lastIndex > self.count) {
        [self removeObjectsAtIndexes:indexes];
        return YES;
    }
    return NO;
}
/// change
- (BOOL)tpExchangeObjectAtIndex:(NSUInteger)index1 withObjectAtIndex:(NSUInteger)index2 {
    if (index1 >= self.count || index2 >= self.count || index1 == index2) return NO;
    [self exchangeObjectAtIndex:index1 withObjectAtIndex:index2];
    return YES;
}
- (BOOL)tpReplaceObjectAtIndex:(NSUInteger)index withObject:(id)anObject {
    if (anObject && index < self.count) {
        [self replaceObjectAtIndex:index withObject:anObject];
        return YES;
    }
    return NO;
}
- (BOOL)tpMoveObjectAtIndex:(NSUInteger)index1 toIndex:(NSUInteger)index2 {
    if (index1 >= self.count || index2 >= self.count || index1 == index2) return NO;
    id obj = [self objectAtIndex:index1];
    [self removeObjectAtIndex:index1];
    [self insertObject:obj atIndex:index2];
    return YES;
}
@end
