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
 @return 观察者对象
 */
- (instancetype)initWithObserved:(NSObject *)observed;
- (void)addObserverForKeyPath:(NSString *)keyPath options:(TPObservingChangeOptions)options block:(TPCustomKVOBlock)block;
- (void)removeObserverForKeyPath:(NSString *)keyPath;
@end
