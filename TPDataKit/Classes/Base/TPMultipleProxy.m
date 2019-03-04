//
//  TPMultipleProxy.m
//  TPKit
//
//  Created by Topredator on 2019/3/2.
//

#import "TPMultipleProxy.h"

@implementation TPMultipleProxy
@synthesize objects = _objects;

- (BOOL)respondsToSelector:(SEL)selector {
    for (id obj in self.objects) {
        if ([obj respondsToSelector:selector]) {
            return YES;
        }
    }
    return NO;
}

+ (instancetype)proxyWithObjects:(NSArray *)objects {
    return [(TPMultipleProxy *)[self alloc] initWithObjects:objects];
}
- (instancetype)initWithObjects:(NSArray *)objects {
    NSPointerArray *array = [NSPointerArray weakObjectsPointerArray];
    for (id obj in objects) {
        [array addPointer:(__bridge void *)(obj)];
    }
    _objects = array;
    return self;
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)sel {
    NSMethodSignature *sign;
    for (id obj in self.objects) {
        sign = [obj methodSignatureForSelector:sel];
        if (sign) {
            break;
        }
    }
    return sign;
}
- (void)forwardInvocation:(NSInvocation *)invocation {
    for (id obj in self.objects) {
        if ([obj respondsToSelector:invocation.selector]) {
            [invocation invokeWithTarget:obj];
        }
    }
}
@end
