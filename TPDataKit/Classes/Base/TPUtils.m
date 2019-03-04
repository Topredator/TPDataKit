//
//  TPUtils.m
//  TPKit
//
//  Created by Topredator on 2019/3/2.
//

#import <objc/runtime.h>

/// GCD主队列
void TPAsyncMainQueue(dispatch_block_t block) {
    dispatch_async(dispatch_get_main_queue(), block);
}
/// GCD默认优先级的全局队列
void TPAsyncDefaultQueue(dispatch_block_t block) {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), block);
}
/// 延迟执行
void TPAfterDispatch(NSTimeInterval delay, dispatch_block_t block) {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), block);
}


void TPInstanceMethodSwizzling(Class originClass, SEL originSelector, SEL swizzledSelector) {
    Method originMethod = class_getInstanceMethod(originClass, originSelector);
    Method swizzledMethod = class_getInstanceMethod(originClass, swizzledSelector);
    if (class_addMethod(originClass, originSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod))) {
        class_replaceMethod(originClass, swizzledSelector, method_getImplementation(originMethod), method_getTypeEncoding(originMethod));
    } else {
        method_exchangeImplementations(originMethod, swizzledMethod);
    }
}
void TPClassAndInstanceMethodSwizzling(Class originClass, Class swizzledClass, SEL originSelector, SEL swizzledSelector) {
    Method originalMethod = class_getInstanceMethod(originClass, originSelector);
    Method swizzlingMethod = class_getInstanceMethod(swizzledClass, swizzledSelector);
    if (class_addMethod(originClass, swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod))) {
        class_replaceMethod(originClass, swizzledSelector, method_getImplementation(swizzlingMethod), method_getTypeEncoding(swizzlingMethod));
    } else {
        method_exchangeImplementations(originalMethod, swizzlingMethod);
    }
}
