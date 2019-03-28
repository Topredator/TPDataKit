//
//  TPCustomeKVO.m
//  TPDataKit
//
//  Created by Topredator on 2019/3/9.
//


#import "NSObject+TPCustomKVO.h"
#import "TPCustomKVO.h"
#import <objc/runtime.h>
#import <objc/message.h>

/// 子类前缀
static NSString * const TPCustomKVOPrefix = @"TPNotify_";

#pragma mark ==================  Common method  ==================
///根据key获取setter方法名
static NSString *_getSetterSelWithKeyPath(NSString *keyPath){
    if(keyPath.length == 0){
        return nil;
    }else{
        NSString *uppercase = [[[keyPath substringToIndex:1] uppercaseString] stringByAppendingString:[keyPath substringFromIndex:1]];
        return [NSString stringWithFormat:@"set%@:",uppercase];
    }
}
///根据setterSel获取key
static NSString *_getKeyPathWithSetterSel(NSString *sel){
    if (sel.length <= 4) {
        return nil;
    }else{
        NSString *uppercase = [sel substringWithRange:NSMakeRange(3, sel.length - 4)];
        return [[[uppercase substringToIndex:1] lowercaseString] stringByAppendingString:[uppercase substringFromIndex:1]];
    }
}
///根据typeEncode获取结构体名字
static NSString *_getStructTypeWithTypeEncode(NSString *typeEncode){
    if (typeEncode.length < 3) {
        return nil;
    }
    NSRange locate = [typeEncode rangeOfString:@"="];
    if (locate.length == 0) {
        return nil;
    }
    return [typeEncode substringWithRange: NSMakeRange(1, locate.location - 1)];
}

@interface _TPObserverInfo_ : NSObject
/// 被观察的属性 字符串
@property (nonatomic, copy) NSString *keyPath;
/// 保存的旧值
@property (nonatomic, strong) id oldValue;
@property (nonatomic, assign) TPObservingChangeOptions options;
///当前key对应的addMethod添加的方法
@property (nonatomic, unsafe_unretained) IMP _childMethod;
///当前key对应的源类中的方法
@property (nonatomic, unsafe_unretained) IMP _superMethod;
///当前key对应的setter selector
@property (nonatomic, unsafe_unretained) SEL _setSel;
///childMethod的typeCoding
@property (nonatomic, copy) NSString *_childMethodTypeCoding;
/// 源类的 class方法的IMP
@property (nonatomic, unsafe_unretained) IMP _classMethod;
/// 保存传入的block
@property (nonatomic, copy) TPCustomKVOBlock block;

/// 属性是否有copy语义
@property (nonatomic, assign) BOOL isCopy;
/// 属性是否有非原子操作
@property (nonatomic, assign) BOOL isNonatomic;
@end

@implementation _TPObserverInfo_

@end

@interface TPCustomKVO ()
/// 被观察者对象
@property (nonatomic, weak) NSObject *observed;
@property (nonatomic, copy) NSString *observerName;


@property (nonatomic, strong) NSMapTable *observerMap;

@property (nonatomic, strong) NSMutableDictionary <NSString *, _TPObserverInfo_ *>*infoContainer;
/// 派生类 类名
@property (nonatomic, copy) NSString *childClassName;
/// 源类
@property (nonatomic, weak) Class tpOriginClass;
/// 派生类
@property (nonatomic, weak) Class tpPrefixClass;
@end

#pragma mark ==================  child methods 用于替换源类中的方法  ==================
static Class _originClass(id obj)
{
    if ([NSStringFromClass(object_getClass(obj)) hasPrefix:TPCustomKVOPrefix]) {
        return class_getSuperclass(object_getClass(obj));
    } else {
        return object_getClass(obj);
    }
}
/// 根据setter selector 获取Info对象
static NSMutableArray<_TPObserverInfo_ *> *fetchInfoObjectFromSetterSEL(id obj, SEL sel) {
    NSString *setterSELStr = NSStringFromSelector(sel);
    NSString *keyPath = _getKeyPathWithSetterSel(setterSELStr);
    NSMutableArray *infos = @[].mutableCopy;
    NSMutableDictionary *kvoMap = [obj TPKVOMap];
    for (NSString *name in kvoMap.allKeys) {
        TPCustomKVO *kvo = kvoMap[name];
        _TPObserverInfo_ *info = [kvo.infoContainer objectForKey:keyPath];
        if (info) {
            [infos addObject:info];
        }
    }
    return infos;
}

/// 当进行赋值操作时，触发block
static void _childSetterNotify(_TPObserverInfo_ *info, id obj, NSString *keyPath, id valueNew) {
    if (!info) return;
    NSMutableDictionary *change = [NSMutableDictionary dictionary];
    if (info.options & TPObservingChangeOptionsOld) {
        if (info.oldValue) change[TPChangeOptionOldKey] = info.oldValue;
    }
    if (info.options & TPObservingChangeOptionsNew) {
        change[TPChangeOptionNewKey] = valueNew;
    }
    // 如果是原子性 保证线程安全
    if (!info.isNonatomic) {
        @synchronized (info) {
            info.oldValue = valueNew;
        }
    } else {
        info.oldValue = valueNew;
    }
    if (info.block) {
        info.block(obj, keyPath, change);
    }
}

/// 当被观察的属性为id类型时，key的setter方法会指向此方法
static void _childSetterObj(id obj, SEL sel, id v) {
    NSMutableArray <_TPObserverInfo_ *>*infos = fetchInfoObjectFromSetterSEL(obj, sel);
    
    for (_TPObserverInfo_ *info in infos) {
        /// 重复值过滤
        if ([obj tpIgnoreDuplicateValues] && info.oldValue == v) return;
        id value = v;
        if (info.isCopy) {
            value = [value copy];
        }
        if (info.isNonatomic) {
            @synchronized (info) {
                ((void (*)(id, SEL, id))info._superMethod)(obj, sel, value);
            }
        } else {
            ((void (*)(id, SEL, id))info._superMethod)(obj, sel, value);
        }
        /// 进行通知
        _childSetterNotify(info, obj, info.keyPath, value);
    }
}

/// 为数值类型的key定义通用宏 ，与_childSetterObj只是类型不同
#define TP_Setter_Number(type, TypeSet, typeGet) \
static void _childSetter##TypeSet(id obj, SEL sel, type v) { \
    NSMutableArray <_TPObserverInfo_ *>*infos = fetchInfoObjectFromSetterSEL(obj, sel); \
    for (_TPObserverInfo_ *info in infos) { \
        if ([obj tpIgnoreDuplicateValues] && [info.oldValue typeGet##Value] == v) return; \
        if (!info.isNonatomic) { \
            @synchronized(info) { \
            ((void (*)(id, SEL, type))info._superMethod)(obj, sel, v); \
        } \
    } else { \
        ((void (*)(id, SEL, type))info._superMethod)(obj, sel, v); \
    } \
_childSetterNotify(info, obj, info.keyPath, [NSNumber numberWith##TypeSet:v]);\
    }\
}

TP_Setter_Number(char, Char, char)
TP_Setter_Number(int, Int, int)
TP_Setter_Number(short, Short, short)
TP_Setter_Number(long, Long, long)
TP_Setter_Number(long long, LongLong, longLong)
TP_Setter_Number(unsigned char, UnsignedChar, unsignedChar)
TP_Setter_Number(unsigned int, UnsignedInt, unsignedInt)
TP_Setter_Number(unsigned short, UnsignedShort, unsignedShort)
TP_Setter_Number(unsigned long, UnsignedLong, unsignedLong)
TP_Setter_Number(unsigned long long, UnsignedLongLong, unsignedLongLong)
TP_Setter_Number(float, Float, float)
TP_Setter_Number(double, Double, double)
TP_Setter_Number(bool, Bool, bool)

/// 为结构体key定义通用宏，结构同_childSetterObj 只是类型不同

#define TP_Setter_Structer(type, equalMethod) \
static void _childSetter##type(id obj, SEL sel, type v) { \
    NSMutableArray <_TPObserverInfo_ *>*infos = fetchInfoObjectFromSetterSEL(obj, sel); \
    for (_TPObserverInfo_ *info in infos) { \
        if ([obj tpIgnoreDuplicateValues] && equalMethod([info.oldValue type##Value], v)) return; \
        if (!info.isNonatomic) { \
            @synchronized (info) { \
                ((void (*)(id, SEL, type))info._superMethod)(obj, sel, v); \
            } \
        } else { \
            ((void (*)(id, SEL, type))info._superMethod)(obj, sel, v); \
        } \
        _childSetterNotify(info, obj, info.keyPath, [NSValue valueWith##type:v]);\
    }\
}
TP_Setter_Structer(CGPoint, CGPointEqualToPoint)
TP_Setter_Structer(CGSize, CGSizeEqualToSize)
TP_Setter_Structer(CGRect, CGRectEqualToRect)

static BOOL _CGVectorIsEqualToVector(CGVector vector, CGVector vector1) {
    return vector.dx == vector1.dx && vector.dy == vector1.dy;
}
TP_Setter_Structer(CGVector, _CGVectorIsEqualToVector)
TP_Setter_Structer(CGAffineTransform, CGAffineTransformEqualToTransform)
TP_Setter_Structer(UIEdgeInsets, UIEdgeInsetsEqualToEdgeInsets)
TP_Setter_Structer(UIOffset, UIOffsetEqualToOffset)

@implementation TPCustomKVO
- (instancetype)initWithObserved:(NSObject *)observed observerName:(NSString *)observerName {
    if (!observed || !observerName)  return nil;
    if (self = [super init]) {
        self.observed = observed;
        self.observerName = observerName;
        self.infoContainer = @{}.mutableCopy;
        NSString *className = NSStringFromClass(observed.class);
        /// 派生类的类名 如(TPNotify_Obj)
        self.childClassName = [className hasPrefix:TPCustomKVOPrefix] ? className : [TPCustomKVOPrefix stringByAppendingString:className];
    }
    return self;
}
#pragma mark ==================  Private method  ==================
/// 是否是正在观察的类
- (BOOL)isObserving {
    return [NSStringFromClass(object_getClass(self.observed)) hasPrefix:TPCustomKVOPrefix];
}
#pragma mark ==================  对info对象的 增、删、查 操作   ==================
- (BOOL)addInfo:(_TPObserverInfo_ *)info {
    if (!info || self.infoContainer[info.keyPath]) return NO;
    self.infoContainer[info.keyPath] = info;
    return YES;
}
- (void)removeInfoWithKeyPath:(NSString *)keyPath {
    [self.infoContainer removeObjectForKey:keyPath];
}
- (nullable _TPObserverInfo_ *)infoWithKeyPath:(NSString *)keyPath {
    if (!keyPath || !keyPath.length) return nil;
    return self.infoContainer[keyPath];
}
/// 安全设置当前class
- (void)safeThreadSetClass:(Class)cls {
    if (cls == [self safeThreadGetClass]) {
        return;
    }
    @synchronized (self.observed) {
        object_setClass(self.observed, cls);
    }
}
/// 安全获取class
- (Class)safeThreadGetClass {
    @synchronized (self.observed) {
        return object_getClass(self.observed);
    }
}
/// 检查属性的 copy语义和 非原子性
- (void)checkPropertyMessageWithInfo:(_TPObserverInfo_ *)info {
    if (!info) return;
    objc_property_t property = class_getProperty([self tpOriginClass], info.keyPath.UTF8String);
    if (property == NULL) return;
    unsigned int count;
    objc_property_attribute_t *propertyAttributes = property_copyAttributeList(property, &count);
    for (int i = 0; i < count; i++) {
        objc_property_attribute_t propertyAtt = propertyAttributes[i];
        switch (*propertyAtt.name) {
            case 'N':
                info.isNonatomic = YES;
                break;
            case 'C':
                info.isCopy = YES;
                break;
            default:
                break;
        }
    }
    free(propertyAttributes);
}
/// 生成info对象
- (_TPObserverInfo_ *)generateKVOInfoWithKeyPath:(NSString *)keyPath options:(TPObservingChangeOptions)options block:(TPCustomKVOBlock)block {
    /// 是否已经存在
    _TPObserverInfo_ *existInfo = [self infoWithKeyPath:keyPath];
    if (existInfo) return existInfo;
    ///只有setter方法没有getter方法是无法成功监听的，这里获取getter方法的typeCoding
    const char *getterTypeCode = method_getTypeEncoding(class_getInstanceMethod([self tpOriginClass], NSSelectorFromString(keyPath)));
    /// 获取class方法的编码类型，方便后面isa指针的回指
    const char *classTypeCode = method_getTypeEncoding(class_getInstanceMethod([self tpOriginClass], @selector(class)));
    if (!getterTypeCode || !classTypeCode) {
        return nil;
    }
    IMP childMethod = NULL;
    NSString *childMethodTypeCoding = nil;
    /// 根据keyPath的不同类型，对应不同的方法实现
    switch (*getterTypeCode) {
        case 'c':
            childMethod = (IMP)_childSetterChar;
            childMethodTypeCoding = @"v@:c";
            break;
        case 'i':
            childMethod = (IMP)_childSetterInt;
            childMethodTypeCoding = @"v@:i";
            break;
        case 's':
            childMethod = (IMP)_childSetterShort;
            childMethodTypeCoding = @"v@:s";
            break;
        case 'l':
            childMethod = (IMP)_childSetterLong;
            childMethodTypeCoding = @"v@:l";
            break;
        case 'q':
            childMethod = (IMP)_childSetterLongLong;
            childMethodTypeCoding = @"v@:q";
            break;
        case 'C':
            childMethod = (IMP)_childSetterUnsignedChar;
            childMethodTypeCoding = @"v@:C";
            break;
        case 'I':
            childMethod = (IMP)_childSetterUnsignedInt;
            childMethodTypeCoding = @"v@:I";
            break;
        case 'S':
            childMethod = (IMP)_childSetterUnsignedShort;
            childMethodTypeCoding = @"v@:S";
            break;
        case 'L':
            childMethod = (IMP)_childSetterUnsignedLong;
            childMethodTypeCoding = @"v@:L";
            break;
        case 'Q':
            childMethod = (IMP)_childSetterUnsignedLongLong;
            childMethodTypeCoding = @"v@:Q";
            break;
        case 'f':
            childMethod = (IMP)_childSetterFloat;
            childMethodTypeCoding = @"v@:f";
            break;
        case 'd':
            childMethod = (IMP)_childSetterDouble;
            childMethodTypeCoding = @"v@:d";
            break;
        case 'B':
            childMethod = (IMP)_childSetterBool;
            childMethodTypeCoding = @"v@:B";
            break;
        case '@':
            childMethod = (IMP)_childSetterObj;
            childMethodTypeCoding = @"v@:@";
            break;
        case '{': {
            NSString *typeEncode = [NSString stringWithUTF8String:getterTypeCode];
            NSString *structType = _getStructTypeWithTypeEncode(typeEncode);
            if ([structType isEqualToString: @"CGSize"]) {
                childMethod = (IMP)_childSetterCGSize;
                childMethodTypeCoding = @"v@:{CGSize=dd}";
            }else if([structType isEqualToString: @"CGPoint" ]) {
                childMethod = (IMP)_childSetterCGPoint;
                childMethodTypeCoding = @"v@:{CGPoint=dd}";
            }else if([structType isEqualToString: @"CGRect" ]) {
                childMethod = (IMP)_childSetterCGRect;
                childMethodTypeCoding = @"v@:{CGRect={CGPoint=dd}{CGSize=dd}}";
            }else if([structType isEqualToString: @"CGVector"]) {
                childMethod = (IMP)_childSetterCGVector;
                childMethodTypeCoding = @"v@:{CGVector=dd}";
            }else if([structType isEqualToString: @"CGAffineTransform"]) {
                childMethod = (IMP)_childSetterCGAffineTransform;
                childMethodTypeCoding = @"v@:{CGAffineTransform=dddddd}";
            }else if([structType isEqualToString: @"UIEdgeInsets"]) {
                childMethod = (IMP)_childSetterUIEdgeInsets;
                childMethodTypeCoding = @"v@:{UIEdgeInsets=dddd}";
            }else if([structType isEqualToString: @"UIOffset"]) {
                childMethod = (IMP)_childSetterUIOffset;
                childMethodTypeCoding = @"v@:{UIOffset=dd}";
            }
        }
            break;
        default: // 除了以上类型，不识别其他类型
            return nil;
            break;
    }
    _TPObserverInfo_ *info = [[_TPObserverInfo_ alloc] init];
    info.keyPath = keyPath;
    info.block = block;
    info.options = options;
    info._childMethod = childMethod;
    info._childMethodTypeCoding = childMethodTypeCoding;
    
    /// 获取源类的setter方法
    SEL setterSel = NSSelectorFromString(_getSetterSelWithKeyPath(keyPath));
    IMP superMethod = class_getMethodImplementation([self isObserving] ? self.tpOriginClass : [self safeThreadGetClass], setterSel);
    
    info._setSel = setterSel;
    info._superMethod = superMethod;
    info._classMethod = (IMP)_originClass;
    /// 检查是否存在 copy语义和 非原子性
    [self checkPropertyMessageWithInfo:info];
    return info;
}
- (void)addClassAndMethodWithInfoObject:(_TPObserverInfo_ *)info {
    Class prefixClass = self.tpPrefixClass;
    // 如果已经存在，说明正在观察，不需要重新创建
    if (!prefixClass){
        // 创建并注册
        prefixClass = objc_allocateClassPair([self tpOriginClass], self.childClassName.UTF8String, 0);
        objc_registerClassPair(prefixClass);
        self.tpPrefixClass = prefixClass;
    } ;
    //派生类的set方法，是否与自己创建的setter方法(info._childMethod)地址一致，如果不是需要进行替换
    BOOL needAdd = YES;
    Method currentSetterMethod = class_getInstanceMethod(prefixClass, info._setSel);
    if (currentSetterMethod != NULL) {
        IMP currentSetterIMP = method_getImplementation(currentSetterMethod);
        needAdd = currentSetterIMP != info._childMethod;
    }
    if (needAdd) {
        class_addMethod(prefixClass, info._setSel, info._childMethod, info._childMethodTypeCoding.UTF8String);
        /// isa指针回指 源类
        Method classMethod = class_getInstanceMethod([self tpOriginClass], @selector(class));
        const char *types = method_getTypeEncoding(classMethod);
        class_addMethod(prefixClass, @selector(class), info._classMethod, types);
    }
    /// 设置class，即替换 class 与 prefix_class
    [self safeThreadSetClass:prefixClass];
}
#pragma mark ==================  lazy method  ==================
- (Class)tpPrefixClass {
    if (!_tpPrefixClass) {
        _tpPrefixClass = NSClassFromString(self.childClassName);
    }
    return _tpPrefixClass;
}
- (Class)tpOriginClass {
    if ([self isObserving]) {
        if (!_tpOriginClass) {
            _tpOriginClass = class_getSuperclass([self tpPrefixClass]);
        }
        return _tpOriginClass;
    }
    return object_getClass(self.observed);
}
- (NSMapTable *)observerMap {
    if (!_observerMap) {
        _observerMap = [NSMapTable strongToWeakObjectsMapTable];
    }
    return _observerMap;
}
#pragma mark ==================  Public method  ==================
- (void)addObserverForKeyPath:(NSString *)keyPath options:(TPObservingChangeOptions)options block:(TPCustomKVOBlock)block {
    // 参数检测
    if (!self.observed ||
        !keyPath || ![keyPath isKindOfClass:NSString.class] ||
        ![self.observed respondsToSelector:NSSelectorFromString(_getSetterSelWithKeyPath(keyPath))] ||
        !block) {
        return;
    }
    // 生成并保存info对象
    _TPObserverInfo_ *info = [self generateKVOInfoWithKeyPath:keyPath options:options block:block];
    [self addInfo:info];
    // 添加新的派生类及添加方法
    [self addClassAndMethodWithInfoObject:info];
}
- (void)removeObserverForKeyPath:(NSString *)keyPath {
    if (!keyPath || !keyPath.length) return;
    
    _TPObserverInfo_ *info = [self infoWithKeyPath:keyPath];
    if (!info) return;
    /// 删除infoContainer中keyPath对应的info对象
    [self removeInfoWithKeyPath:keyPath];
    
    if (self.infoContainer.count == 0) {
        [self.observed.TPKVOMap removeObjectForKey:self.observerName];
    }
    
}
@end
