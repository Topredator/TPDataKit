//
//  TPCustomeKVO.h
//  TPDataKit
//
//  Created by Topredator on 2019/3/9.
//

#import <Foundation/Foundation.h>
#import "TPObservingChangeOptions.h"


typedef void(^TPCustomKVOBlock)(NSObject *obj, NSString *keyPath, NSDictionary *change);

@interface TPCustomKVO : NSObject
/**
 初始化

 @param observed 被观察者对象
 @param observerName 观察者名称
 @return 管理观察者的对象
 */
- (instancetype)initWithObserved:(NSObject *)observed observerName:(NSString *)observerName;

- (void)addObserverForKeyPath:(NSString *)keyPath options:(TPObservingChangeOptions)options block:(TPCustomKVOBlock)block;
- (void)removeObserverForKeyPath:(NSString *)keyPath;
@end
