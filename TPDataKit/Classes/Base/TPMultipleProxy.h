//
//  TPMultipleProxy.h
//  TPKit
//
//  Created by Topredator on 2019/3/2.
//

#import <Foundation/Foundation.h>

/**
 方法转发代理，可以将一个方法转发到多个对象
 按照设置对象的顺序，依次转发方法
 如果转发的方法带有返回值，将会以最后一个实现了该方法的对象为准
 */
@interface TPMultipleProxy : NSProxy
@property (nonatomic, strong, readonly) NSPointerArray *objects;

/**
 初始化转发代理

 @param objects 需要转发的对象
 @return 转发代理对象
 */
+ (instancetype)proxyWithObjects:(NSArray *)objects;
- (instancetype)initWithObjects:(NSArray *)objects;

- (BOOL)respondsToSelector:(SEL)selector;
@end


