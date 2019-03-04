//
//  TPKitNavigationController.m
//  TPKit
//
//  Created by Topredator on 2019/3/4.
//

#import "TPKitNavigationController.h"
#import <objc/runtime.h>
#import "TPUtils.h"
#import "TPMultipleProxy.h"

@interface TPNavigationItem ()
@property (nonatomic, weak) UINavigationController *navigationController;
@property (nonatomic, assign, readwrite) BOOL isViewAppearing;
@property (nonatomic, assign, readwrite) BOOL isViewDisapearing;
- (void)updateNavigationBarHiddenAnimated:(BOOL)animated;
@end
@implementation TPNavigationItem
- (void)setNavigationBarHidden:(BOOL)navigationBarHidden {
    [self setNavigationBarHidden:navigationBarHidden animated:NO];
}
- (void)setNavigationBarHidden:(BOOL)navigationBarHidden animated:(BOOL)animated {
    _navigationBarHidden = navigationBarHidden;
    [self updateNavigationBarHiddenAnimated:animated];
}
- (void)updateNavigationBarHiddenAnimated:(BOOL)animated {
    if (self.navigationController && self.navigationController.navigationBarHidden != _navigationBarHidden) {
        [self.navigationController setNavigationBarHidden:_navigationBarHidden animated:animated];
    }
}
@end

static char kTPNavigationItemKey;
@implementation UIViewController (TPNavigationItem)
@dynamic tpNavigationItem;
- (TPNavigationItem *)tpNavigationItem {
    TPNavigationItem *item = objc_getAssociatedObject(self, &kTPNavigationItemKey);
    if (!item) {
        item = [TPNavigationItem new];
        objc_setAssociatedObject(self, &kTPNavigationItemKey, item, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return item;
}
+ (void)load {
    TPInstanceMethodSwizzling(self, @selector(viewWillAppear:), @selector(_tp_viewWillAppear:));
    TPInstanceMethodSwizzling(self, @selector(viewDidAppear:), @selector(_tp_viewDidAppear:));
    TPInstanceMethodSwizzling(self, @selector(viewWillDisappear:), @selector(_tp_viewWillDisappear:));
    TPInstanceMethodSwizzling(self, @selector(viewDidDisappear:), @selector(_tp_viewDidDisappear:));
}
- (void)_tp_viewWillAppear:(BOOL)animated {
    self.tpNavigationItem.isViewAppearing = YES;
    [self _tp_viewWillAppear:animated];
}
- (void)_tp_viewDidAppear:(BOOL)animated {
    if (self.navigationItem) {
        self.tpNavigationItem.isViewAppearing = NO;
        if (self.tpNavigationItem.isViewDisapearing) {
            TPAsyncMainQueue(^{
                [self.tpNavigationItem updateNavigationBarHiddenAnimated:NO];
            });
            [self.tpNavigationItem updateNavigationBarHiddenAnimated:NO];
        }
    }
    [self _tp_viewDidAppear:animated];
}
- (void)_tp_viewWillDisappear:(BOOL)animated {
    self.tpNavigationItem.isViewDisapearing = YES;
    [self _tp_viewWillDisappear:animated];
}
- (void)_tp_viewDidDisappear:(BOOL)animated {
    self.tpNavigationItem.isViewDisapearing = NO;
    [self _tp_viewDidDisappear:animated];
}
@end

@interface TPKitNavigationController () <UIGestureRecognizerDelegate>
@property (nonatomic, weak) id <UINavigationControllerDelegate> targetDelegate;
@property (nonatomic, strong) TPMultipleProxy *delegateProxy;
@end

@implementation TPKitNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.interactivePopGestureRecognizer.delegate = self;
    [super setDelegate:self];
}
//支持旋转
-(BOOL)shouldAutorotate{
    return [self.topViewController shouldAutorotate];
}
//支持的方向
- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return [self.topViewController supportedInterfaceOrientations];
}
//默认的方向
- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return [self.topViewController preferredInterfaceOrientationForPresentation];
}
- (void)setDelegate:(id<UINavigationControllerDelegate>)delegate {
    if (delegate) {
        self.delegateProxy = [TPMultipleProxy proxyWithObjects:@[self, delegate]];
        [super setDelegate:(id <UINavigationControllerDelegate>)self.delegateProxy];
    } else {
        [super setDelegate:self];
    }
}
#pragma mark ==================  UIGestureRecognizerDelegate   ==================
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if (gestureRecognizer == self.interactivePopGestureRecognizer) {
        if (self.viewControllers.count < 2 || self.visibleViewController == [self.viewControllers objectAtIndex:0]) {
            return NO;
        }
        UIViewController *topVC = [self topViewController];
        /// 自定义不能响应
        if (topVC.tpNavigationItem.disableInteractivePopGestureRecognizer) {
            return NO;
        }
    }
    return YES;
}
#pragma mark ==================  UINavigationControllerDelegate   ==================
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if ([self.targetDelegate respondsToSelector:@selector(navigationController:willShowViewController:animated:)]) {
        [self.targetDelegate navigationController:navigationController willShowViewController:viewController animated:animated];
    }
    viewController.tpNavigationItem.navigationController = self;
    [viewController.tpNavigationItem updateNavigationBarHiddenAnimated:animated];
}
- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if ([self respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.interactivePopGestureRecognizer.enabled = !viewController.tpNavigationItem.disableInteractivePopGestureRecognizer;
    }
    if ([self.targetDelegate respondsToSelector:@selector(navigationController:didShowViewController:animated:)]) {
        [self.targetDelegate navigationController:navigationController didShowViewController:viewController animated:animated];
    }
}
@end
