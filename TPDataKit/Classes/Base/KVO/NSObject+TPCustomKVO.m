//
//  NSObject+TPCustomeKVO.m
//  TPDataKit
//
//  Created by Topredator on 2019/3/9.
//

#import "NSObject+TPCustomKVO.h"
#import <objc/runtime.h>
#import "TPCustomKVO.h"

static char kTPCustomKVOKey;
static char kTPIgnoreDuplicateValuesKey;
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
- (TPCustomKVO *)TPCustomKVO {
    TPCustomKVO *customKVO = objc_getAssociatedObject(self, &kTPCustomKVOKey);
    if (!customKVO) {
        customKVO = [[TPCustomKVO alloc] initWithObserved:self];
        objc_setAssociatedObject(self, &kTPCustomKVOKey, customKVO, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return customKVO;
}
- (void)TPAddObserverForKeyPath:(NSString *)keyPath options:(TPObservingChangeOptions)options block:(void (^)(NSObject *, NSString *, NSDictionary *))block {
    [self.TPCustomKVO addObserverForKeyPath:keyPath options:options block:block];
}
- (void)TPRemoveObserverForKeyPath:(NSString *)keyPath {
    [self.TPCustomKVO removeObserverForKeyPath:keyPath];
}
@end
