//
//  UIView+TPTapAction.h
//  TPDataKit
//
//  Created by Topredator on 2019/3/12.
//

#import <UIKit/UIKit.h>


/**
 动态给UIView添加tap点击
 */
@interface UIView (TPTapAction)
- (void)TPTapActionWithBlock:(void (^)(void))block;
@end

