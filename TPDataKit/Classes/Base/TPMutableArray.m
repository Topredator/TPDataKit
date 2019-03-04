//
//  TPMutableArray.m
//  TPKit
//
//  Created by Topredator on 2019/3/4.
//

#import "TPMutableArray.h"


@interface TPArrayKeyedObjectSet : NSObject
@property (nonatomic, strong) NSMapTable *counters;
@property (nonatomic, strong) NSMutableOrderedSet *orderSet;

- (void)addObject:(id)object;
- (void)removeObject:(id)object;
- (NSUInteger)objectReferencesCount:(id)object;
- (NSUInteger)count;
@end

@implementation TPArrayKeyedObjectSet

- (instancetype)init {
    self = [super init];
    if (self) {
        _counters = [NSMapTable mapTableWithKeyOptions:NSPointerFunctionsStrongMemory valueOptions:NSPointerFunctionsStrongMemory];
        _orderSet = [NSMutableOrderedSet orderedSet];
    }
    return self;
}

- (void)addObject:(id)object {
    if (!object) return;
    NSNumber *count = [self.counters objectForKey:object];
    if (!count) {
        [self.orderSet addObject:object];
        [self.counters setObject:@(1) forKey:object];
    } else {
        [self.counters setObject:@([count unsignedIntegerValue] + 1) forKey:object];
    }
}
- (void)removeObject:(id)object {
    if (!object) return;
    NSUInteger count = [[_counters objectForKey:object] unsignedIntegerValue];
    if (count <= 1) {
        [self.counters removeObjectForKey:object];
    } else {
        [self.counters setObject:@(count - 1) forKey:object];
    }
    [self.orderSet removeObject:object];
}
- (NSUInteger)objectReferencesCount:(id)object {
    if (!object) return 0;
    NSNumber *count = [_counters objectForKey:object];
    if (count) {
        return [count unsignedIntegerValue];
    }
    return 0;
}
- (NSUInteger)count {
    return self.orderSet.count;
}
@end

@interface TPMutableArray ()
@property (nonatomic, strong) NSMutableArray *mArray;
@property (nonatomic, strong) NSMutableDictionary *mDictionary;
@property (nonatomic, copy) id mIdentity;
@end
@implementation TPMutableArray
- (id)modelID {
    if (_mIdentity) {
        return _mIdentity;
    }
    return nil;
}
- (nullable instancetype)initWithID:(id<NSCopying>)identity {
    self = [self initWithCapacity:0];
    if (!self) return nil;
    self.mIdentity = identity;
    return self;
}
- (nullable NSArray *)objectsForID:(nullable id)identity {
    TPArrayKeyedObjectSet *orderSet = [self.mDictionary objectForKey:identity];
    return orderSet ? [orderSet.orderSet array] : nil;
}
- (nullable id)firstObjectForID:(nullable id)identity {
    TPArrayKeyedObjectSet *orderSet = [self.mDictionary objectForKey:identity];
    return orderSet ? [orderSet.orderSet firstObject] : nil;
}
- (NSUInteger)firstIndexForID:(nonnull id)identity {
    TPArrayKeyedObjectSet *orderSet = [self.mDictionary objectForKey:identity];
    if (orderSet) {
        return [self.mArray indexOfObjectIdenticalTo:[orderSet.orderSet firstObject]];
    }
    return NSNotFound;
}
- (BOOL)removeObjectsForID:(nonnull id)identity {
    TPArrayKeyedObjectSet *orderSet = [self.mDictionary objectForKey:identity];
    if (orderSet) {
        for (id obj in orderSet.orderSet) {
            [self.mArray removeObject:obj];
        }
        [self.mDictionary removeObjectForKey:identity];
        return YES;
    }
    return NO;
}
#pragma mark ==================  private method  ==================
/// 从字典中设置一个匹配的对象
- (void)_setObjectToDictionaryIfNeeded:(id)object {
    if (object && [object conformsToProtocol:@protocol(TPModelID)]) {
        id identity = [object modelID];
        if (!identity) return;
        TPArrayKeyedObjectSet *set = [self.mDictionary objectForKey:identity];
        if (!set) {
            set = [TPArrayKeyedObjectSet new];
            [self.mDictionary setObject:set forKey:identity];
        }
        [set addObject:object];
    }
}
- (void)_removeObjectInDictionaryIfNeeded:(id)object {
    if (object && [object conformsToProtocol:@protocol(TPModelID)]) {
        id identity = [object modelID];
        if (!identity) return;
        TPArrayKeyedObjectSet *set = [self.mDictionary objectForKey:identity];
        if (set && [set objectReferencesCount:object] > 0) {
            [set removeObject:object];
            if ([set count] == 0) {
                [self.mDictionary removeObjectForKey:identity];
            }
        }
    }
}
#pragma mark ==================  NSArray subclass required ==================
- (NSUInteger)count {
    return self.mArray.count;
}
- (id)objectAtIndex:(NSUInteger)index {
    return [self.mArray objectAtIndex:index];
}
- (instancetype)initWithCapacity:(NSUInteger)numItems {
    if (self = [super init]) {
        _mArray = [[NSMutableArray alloc] initWithCapacity:numItems];
        _mDictionary = @{}.mutableCopy;
    }
    return self;
}
- (void)insertObject:(id)obj atIndex:(NSUInteger)index {
    [self.mArray insertObject:obj atIndex:index];
    [self _setObjectToDictionaryIfNeeded:obj];
}
- (void)removeObjectAtIndex:(NSUInteger)index {
    [self _removeObjectInDictionaryIfNeeded:[self.mArray objectAtIndex:index]];
    [self.mArray removeObjectAtIndex:index];
}
- (void)addObject:(id)obj {
    [self.mArray addObject:obj];
    [self _setObjectToDictionaryIfNeeded:obj];
}
- (void)replaceObjectAtIndex:(NSUInteger)index withObject:(id)obj {
    [self _removeObjectInDictionaryIfNeeded:obj];
    [self.mArray replaceObjectAtIndex:index withObject:obj];
    [self _setObjectToDictionaryIfNeeded:obj];
}
#pragma mark ==================  NSMutableCoping   ==================
- (id)mutableCopyWithZone:(nullable NSZone *)zone {
    TPMutableArray *array = [[[self class] allocWithZone:zone] init];
    array->_mArray = [self.mArray mutableCopyWithZone:zone];
    array->_mDictionary = [self.mDictionary mutableCopyWithZone:zone];
    array.mIdentity = _mIdentity;
    return array;
}
- (id)forwardingTargetForSelector:(SEL)aSelector {
    return self.mArray;
}
@end

@implementation TPMutableArray (TPObjectSubscripting)
- (id)objectForKeyedSubscript:(id)key {
    return [self firstObjectForID:key];
}
@end

@implementation NSArray (TPMutableArray)
- (TPMutableArray *)TPMutableArray {
    return [[TPMutableArray alloc] initWithArray:self];
}

@end
