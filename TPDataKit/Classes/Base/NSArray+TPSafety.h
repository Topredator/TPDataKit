//
//  NSArray+TPSafety.h
//  TPKit
//
//  Created by Topredator on 2019/3/2.
//

#import <Foundation/Foundation.h>


/**
 数组扩展分类
 */
@interface NSArray<ObjectType> (TPSafety)
/// 获取index的值
- (id)tpObjectAtIndex:(NSUInteger)index;
/// 安全拼接数组
- (NSArray *)tpArrayByAddingObjectsFromArray:(NSArray *)otherArray;
/// 创建数组
+ (instancetype)createSafetyArrayWithObject:(ObjectType)anObject;
@end

/**
 可变数组的扩展分类
 支持add、remove、insert、replace、exchange、move等操作，并保证此类操作不会发生数组越界等崩溃
 同时这些操作的返回值：YES--表示数组发生改变；NO--表示数组未发生改变
 */
@interface NSMutableArray<ObjectType> (TPSafety)
#pragma mark ==================  add   ==================
- (BOOL)tpAddObject:(ObjectType)object;
- (BOOL)tpAddObjectsFromArray:(NSArray *)otherArray;
- (BOOL)tpInsertObject:(ObjectType)object atIndex:(NSUInteger)index;
#pragma mark ==================  remove   ==================
- (BOOL)tpRemoveObjectAtIndex:(NSUInteger)index;
- (BOOL)tpRemoveObject:(ObjectType)object;
/// 移除大于等于某个索引的所有对象
- (BOOL)tpRemoveObjectsAfterIndex:(NSUInteger)index;
/// 移除小于等于某个索引的所有对象
- (BOOL)tpRemoveObjectsBeforeIndex:(NSUInteger)index;
- (BOOL)tpRemoveObjectsInRange:(NSRange)range;
- (BOOL)tpRemoveObjectsAtIndexes:(NSIndexSet *)indexes;
#pragma mark ==================  change   ==================
- (BOOL)tpExchangeObjectAtIndex:(NSUInteger)index1 withObjectAtIndex:(NSUInteger)index2;
- (BOOL)tpReplaceObjectAtIndex:(NSUInteger)index withObject:(ObjectType)anObject;
- (BOOL)tpMoveObjectAtIndex:(NSUInteger)index1 toIndex:(NSUInteger)index2;
@end


