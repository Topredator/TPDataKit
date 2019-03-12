//
//  UIView+TPTapAction.m
//  TPDataKit
//
//  Created by Topredator on 2019/3/12.
//

#import "UIView+TPTapAction.h"
#import <objc/runtime.h>

static char kTPTapGestureKey;
static char kTPTapBlockKey;

@implementation UIView (TPTapAction)
- (void)TPTapActionWithBlock:(void (^)(void))block {
    UITapGestureRecognizer *tapGR = objc_getAssociatedObject(self, &kTPTapGestureKey);
    if (!tapGR) {
        tapGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_TPHandlerActionForTapGesture:)];
        [self addGestureRecognizer:tapGR];
        objc_setAssociatedObject(self, &kTPTapGestureKey, tapGR, OBJC_ASSOCIATION_RETAIN);
    }
    objc_setAssociatedObject(self, &kTPTapBlockKey, block, OBJC_ASSOCIATION_COPY);
}


- (void)_TPHandlerActionForTapGesture:(UITapGestureRecognizer *)tapGesture {
    if (tapGesture.state == UIGestureRecognizerStateRecognized) {
        void (^tapAction)(void) = objc_getAssociatedObject(self, &kTPTapBlockKey);
        if (tapAction) tapAction();
    }
}
@end
