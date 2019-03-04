//
//  NSDictionary+TPSafety.h
//  TPKit
//
//  Created by Topredator on 2019/3/2.
//

#import <Foundation/Foundation.h>


/**
 字典的扩展
 支持取值后直接转化 BOOL/double/NSInteger 类型
 */
@interface NSDictionary (TPSafety)
/**
 获取字段的对象，并根据对象的类型进行验证对象的合法性

 @param key 对象的键值
 @param objClass 对象的值
 @return 对象验证失败返回nil，成功返回对象
 */
- (id)tpObjectForKey:(id)key validatedByClass:(Class)objClass;

- (NSString *)tpStringObjectForKey:(id)key;
- (NSNumber *)tpNumberObjectForKey:(id)key;
- (NSValue *)tpValueObjectForKey:(id)key;
- (NSArray *)tpArrayObjectForKey:(id)key;
- (NSDictionary *)tpDictionaryObjectForKey:(id)key;
- (BOOL)tpBoolObjectForKey:(id)key;
- (double)tpDoubleObjectForKey:(id)key;
- (NSInteger)tpIntegerObjectForKey:(id)key;
@end


/**
 可变字典的扩展
 让插入与删除更加安全
 */
@interface NSMutableDictionary (TPSafety)
- (void)tpSetObject:(id)object forKey:(id)key;
- (void)tpRemoveObjectForKey:(id)key;
@end
