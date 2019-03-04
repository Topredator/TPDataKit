//
//  TPKitNavigationController.h
//  TPKit
//
//  Created by Topredator on 2019/3/4.
//

#import <UIKit/UIKit.h>


@interface TPNavigationItem : NSObject
@property (nonatomic, assign, readonly) BOOL isViewAppearing;
@property (nonatomic, assign, readonly) BOOL isViewDisapearing;
/// 隐藏navigationbar
@property (nonatomic, assign) BOOL navigationBarHidden;
/// 禁用右滑返回
@property (nonatomic, assign) BOOL disableInteractivePopGestureRecognizer;
- (void)setNavigationBarHidden:(BOOL)navigationBarHidden animated:(BOOL)animated;
@end


@interface UIViewController (TPNavigationItem)
@property (nonatomic, strong, readonly, nullable) TPNavigationItem *tpNavigationItem;
@end

@interface TPKitNavigationController : UINavigationController <UINavigationControllerDelegate>

@end

