//
//  NSObject+TPNotification.m
//  TPKit
//
//  Created by Topredator on 2019/3/2.
//

#import "NSObject+TPNotification.h"
#import <objc/runtime.h>


@interface _TPNotifyObserveMap : NSObject
/// 存储 通知name：map
@property (nonatomic, strong) NSMutableDictionary *dict;
@end

@implementation _TPNotifyObserveMap
- (instancetype)init {
    self = [super init];
    if (self) {
        self.dict = @{}.mutableCopy;
    }
    return self;
}
- (void)dealloc {
    [self tpRemoveAllObservers];
}
- (void)tpSetObserver:(id)observer forKey:(NSString *)key object:(id)object {
    NSMapTable *map = self.dict[key];
    object = object ?: nil;
    if (!map) {
        map = [NSMapTable weakToStrongObjectsMapTable];
        [map setObject:observer forKey:object];
        [self.dict setObject:map forKey:key];
    } else {
        id oldObserver = [map objectForKey:object];
        if (oldObserver) {
            [NSNotificationCenter.defaultCenter removeObserver:observer];
        }
        [map setObject:observer forKey:object];
    }
}
- (id)tpObserverForKey:(NSString *)key object:(id)object {
    NSMapTable *map = self.dict[key];
    return map ? [map objectForKey:object] : nil;
}
- (void)tpRemoveAllObservers {
    NSArray *allValues = self.dict.allValues;
    for (NSMapTable *map in allValues) {
        for (id observer in map.objectEnumerator) {
            [NSNotificationCenter.defaultCenter removeObserver:observer];
        }
    }
    [self.dict removeAllObjects];
}
- (void)tpRemoveObserverForKey:(NSString *)key object:(id)object {
    NSMapTable *map = [self.dict objectForKey:key];
    if (!map) return;
    if (object) {
        id observer = [map objectForKey:object];
        if (!observer) return;
        [NSNotificationCenter.defaultCenter removeObserver:observer];
        [map removeObjectForKey:object];
        if (map.count == 0) {
            [self.dict removeObjectForKey:key];
        }
    } else {
        for (id observer in map.objectEnumerator) {
            [NSNotificationCenter.defaultCenter removeObserver:observer];
        }
        [self.dict removeObjectForKey:key];
    }
}
- (BOOL)isEmpty {
    return self.dict.count == 0;
}
@end

static char kTPNotifyObserveKey;

@implementation NSObject (TPNotification)
- (id)tpObserveNOtificaitonByName:(NSString *)name notifyBlock:(TPNotifyBlock)block {
    return [self tpObserveNOtificaitonByName:name object:nil notifyBlock:block];
}
- (id)tpObserveNOtificaitonByName:(NSString *)name object:(id)object notifyBlock:(TPNotifyBlock)block {
    NSOperationQueue *mainQueue = [NSOperationQueue mainQueue];
    id observer = [NSNotificationCenter.defaultCenter addObserverForName:name object:object queue:mainQueue usingBlock:block];
    _TPNotifyObserveMap *map = objc_getAssociatedObject(self, &kTPNotifyObserveKey);
    if (!map) {
        map = [_TPNotifyObserveMap new];
        objc_setAssociatedObject(self, &kTPNotifyObserveKey, map, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    [map tpSetObserver:observer forKey:name object:object];
    return observer;
}
- (id)tpObserveNOtificaitonByName:(NSString *)name selector:(SEL)selector {
    return [self tpObserveNOtificaitonByName:name object:nil selector:selector];
}
- (id)tpObserveNOtificaitonByName:(NSString *)name object:(id)object selector:(SEL)selector {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    __weak typeof(self) weakSelf = self;
    return [self tpObserveNOtificaitonByName:name object:object notifyBlock:^(NSNotification *note) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf performSelector:selector withObject:note];
    }];
#pragma clang diagnostic pop
}
- (BOOL)tpIsObservedNotificationByName:(NSString *)name {
    _TPNotifyObserveMap *map = objc_getAssociatedObject(self, &kTPNotifyObserveKey);
    if (map) {
        if ([map tpObserverForKey:name object:nil]) {
            return YES;
        }
    }
    return NO;
}


- (void)tpRemoveAllObserveNotificaitons {
    _TPNotifyObserveMap *map = objc_getAssociatedObject(self, &kTPNotifyObserveKey);
    if (map) {
        [map tpRemoveAllObservers];
        objc_setAssociatedObject(self, &kTPNotifyObserveKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
}
- (void)tpRemoveObservedNotificationByName:(NSString *)name {
    [self tpRemoveObservedNotificationByName:name object:nil];
}
- (void)tpRemoveObservedNotificationByName:(NSString *)name object:(id)object {
    _TPNotifyObserveMap *map = objc_getAssociatedObject(self, &kTPNotifyObserveKey);
    if (map) {
        [map tpRemoveObserverForKey:name object:object];
        if ([map isEmpty]) {
            objc_setAssociatedObject(self, &kTPNotifyObserveKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        }
    }
}
@end
