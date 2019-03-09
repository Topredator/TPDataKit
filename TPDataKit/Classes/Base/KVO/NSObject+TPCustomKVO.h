//
//  NSObject+TPCustomeKVO.h
//  TPDataKit
//
//  Created by Topredator on 2019/3/9.
//

#import <Foundation/Foundation.h>
#import "TPObservingChangeOptions.h"

@interface NSObject (TPCustomKVO)
/// 是否忽视重复的值
@property (nonatomic, assign) BOOL tpIgnoreDuplicateValues;
/**
 开始观察属性

 @param keyPath 属性的字符串
 @param options 更改的字典中，是否包含 TPChangeOldKey 和 TPChangeNewKey 条目
 @param block 通知回调
 */
- (void)TPAddObserverForKeyPath:(NSString *)keyPath options:(TPObservingChangeOptions)options block:(void (^)(NSObject *obj, NSString *keyPath, NSDictionary *change))block;

/**
 取消观察属性

 @param keyPath 属性的字符串
 */
- (void)TPRemoveObserverForKeyPath:(NSString *)keyPath;
@end

