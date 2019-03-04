//
//  TPMutableArray.h
//  TPKit
//
//  Created by Topredator on 2019/3/4.
//

#import <Foundation/Foundation.h>

#import "TPModelID.h"

NS_ASSUME_NONNULL_BEGIN

@interface TPMutableArray<__covariant ObjectType> : NSMutableArray <TPModelID>

/**
 初始化方法

 @param identity 身份ID标识符
 */
- (nullable instancetype)initWithID:(nullable id<NSCopying>)identity;

/**
 根据身份ID标识符查找对象

 @param identity 身份ID
 @return 查找的对象，nil表示没有找到
 */
- (nullable NSArray <ObjectType<TPModelID>>*)objectsForID:(nullable id)identity;

/**
 根据身份ID查找第一个对象

 @param identity 身份ID
 @return 查找的对象，nil表示没有找到
 */
- (nullable ObjectType<TPModelID>)firstObjectForID:(nullable id)identity;

/**
 根据身份ID查找第一个对象的下标

 @param identity 身份ID
 @return 查找的第一个对象相应的下标，NSNotFound表示没有找到
 */
- (NSUInteger)firstIndexForID:(nonnull id)identity;

/**
 删除 身份ID标识符 匹配的所有对象

 @param identity 身份ID
 @return YES删除成功，NO失败
 */
- (BOOL)removeObjectsForID:(nonnull id)identity;
/**
 添加对象，如果对象支持CKDataModel协议，并且identity不为nil，可以用objectForID查找到该对象
 注意，如果数组内已经存在一个相同标识符的对象，两个对象同时存在
 @param anObject 新对象
 */
- (void)addObject:(nonnull ObjectType)anObject;
@end

@interface TPMutableArray (TPObjectSubscripting)
/**
 根据标识符查找对象
 @param key 标识符
 @return nil：表示没有找到匹配的对象
 */
- (nullable id)objectForKeyedSubscript:(nonnull id)key;
@end

@interface NSArray (TPMutableArray)
- (nonnull TPMutableArray *)TPMutableArray;
@end

NS_ASSUME_NONNULL_END
