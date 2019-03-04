//
//  NSObject+TPNotification.h
//  TPKit
//
//  Created by Topredator on 2019/3/2.
//

#import <Foundation/Foundation.h>


typedef void(^TPNotifyBlock)(NSNotification *note);

@interface NSObject (TPNotification)

/// 监听通知, 如果self释放，将会自动清除，无需手动处理；返回observe对象
- (id)tpObserveNOtificaitonByName:(NSString *)name notifyBlock:(TPNotifyBlock)block;
- (id)tpObserveNOtificaitonByName:(NSString *)name object:(id)object notifyBlock:(TPNotifyBlock)block;
- (id)tpObserveNOtificaitonByName:(NSString *)name selector:(SEL)selector;
- (id)tpObserveNOtificaitonByName:(NSString *)name object:(id)object selector:(SEL)selector;
- (BOOL)tpIsObservedNotificationByName:(NSString *)name;

/// 删除通知
- (void)tpRemoveAllObserveNotificaitons;
- (void)tpRemoveObservedNotificationByName:(NSString *)name;
- (void)tpRemoveObservedNotificationByName:(NSString *)name object:(id)object;
@end

