//
//  NSObject+TPCustomeKVO.m
//  TPDataKit
//
//  Created by Topredator on 2019/3/9.
//

#import "NSObject+TPCustomKVO.h"
#import <objc/runtime.h>
#import "TPCustomKVO.h"

static char kTPIgnoreDuplicateValuesKey;

static char kTPKVOMapKey;

@interface NSObject ()
@property (nonatomic, strong) NSMutableDictionary *TPKVOMap;
@end

@implementation NSObject (TPCustomKVO)
- (void)setTpIgnoreDuplicateValues:(BOOL)tpIgnoreDuplicateValues {
    objc_setAssociatedObject(self, &kTPIgnoreDuplicateValuesKey, @(tpIgnoreDuplicateValues), OBJC_ASSOCIATION_ASSIGN);
}
- (BOOL)tpIgnoreDuplicateValues {
    id duplicateValue = objc_getAssociatedObject(self, &kTPIgnoreDuplicateValuesKey);
    if ([duplicateValue respondsToSelector:@selector(boolValue)]) {
        return [duplicateValue boolValue];
    }
    return NO;
}


/**
 TPKVOMap的作用:
 每一个观察者对应一个TPCustomKVO对象，TPCustomKVO对象面管理一个不同key的处理的字典
 */
- (NSMutableDictionary *)TPKVOMap {
    NSMutableDictionary *kvoMap = objc_getAssociatedObject(self, &kTPKVOMapKey);
    if (!kvoMap) {
        kvoMap = [NSMutableDictionary dictionary];
        objc_setAssociatedObject(self, &kTPKVOMapKey, kvoMap, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return kvoMap;
}
- (void)TPAddObserver:(id)observer keyPath:(NSString *)keyPath options:(TPObservingChangeOptions)options block:(void (^)(NSObject *obj, NSString *keyPath, NSDictionary *change))block {
    if (!observer) return;
    NSString *observerName = NSStringFromClass([observer class]);
    TPCustomKVO *customKvo = [[self TPKVOMap] valueForKey:observerName];
    if (!customKvo) {
        customKvo = [[TPCustomKVO alloc] initWithObserved:self observerName:observerName];
        [[self TPKVOMap] setValue:customKvo forKey:observerName];
    }
    [customKvo addObserverForKeyPath:keyPath options:options block:block];
}
- (void)TPRemoveObserver:(id)observer keyPath:(NSString *)keyPath {
    if (!observer) return;
    TPCustomKVO *customKvo = [[self TPKVOMap] valueForKey:NSStringFromClass([observer class])];
    [customKvo removeObserverForKeyPath:keyPath];
}



@end
