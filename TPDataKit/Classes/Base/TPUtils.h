//
//  TPUtils.h
//  TPKit
//
//  Created by Topredator on 2019/3/2.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


#define TPRGB(r, g, b)         [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f alpha:1]
#define TPRGBA(r, g, b, a)    [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f alpha:(a)]
#define TPHEXCOLOR(v)      TPRGB((v & 0xff0000) >> 16, (v & 0xff00) >> 8, (v & 0xff))

/// GCD主队列
void TPAsyncMainQueue(dispatch_block_t block);
/// GCD默认优先级的全局队列
void TPAsyncDefaultQueue(dispatch_block_t block);
/// 延迟执行
void TPAfterDispatch(NSTimeInterval delay, dispatch_block_t block);

/**
 交换类的实例方法
 @param originClass 需要交换的类
 @param originSelector 交换前的实例方法
 @param swizzledSelector 交换后的实例方法
 */
void TPInstanceMethodSwizzling(Class originClass, SEL originSelector, SEL swizzledSelector);
/**
 交换类 与 类的实例方法
 */
void TPClassAndInstanceMethodSwizzling(Class originClass, Class swizzledClass, SEL originSelector, SEL swizzledSelector);
