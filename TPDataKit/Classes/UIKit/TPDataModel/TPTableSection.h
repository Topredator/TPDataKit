//
//  TPTableSection.h
//  TPKit
//
//  Created by Topredator on 2019/3/4.
//

#import "TPMutableArray.h"

@class TPTableViewProxy;
@class TPTableSection;

/// section height
typedef CGFloat (^TPTableSectionHeightBlock)(__kindof TPTableSection *sectionData, TPTableViewProxy *proxy, NSUInteger section);
/// section初始化 header/footer
typedef CGFloat (^TPTableSectionPreparedBlock)(__kindof TPTableSection *sectionData, TPTableViewProxy *proxy, __kindof UITableViewHeaderFooterView *view, NSUInteger section);


@protocol TPTableViewSectionDelegate <NSObject>
- (CGFloat)TPTableViewHeaderHeightWithTableViewProxy:(TPTableViewProxy *)proxy section:(NSUInteger)section;
- (CGFloat)TPTableViewFooterHeightWithTableViewProxy:(TPTableViewProxy *)proxy section:(NSUInteger)section;
- (void)TPTableViewHeader:(__kindof UITableViewHeaderFooterView *)header preparedWithTableViewProxy:(TPTableViewProxy *)proxy section:(NSUInteger)section;
- (void)TPTableViewFooter:(__kindof UITableViewHeaderFooterView *)footer preparedWithTableViewProxy:(TPTableViewProxy *)proxy section:(NSUInteger)section;
@end

@interface TPTableSection<__covariant ObjectType> : TPMutableArray<TPTableViewSectionDelegate>
/// 自身可携带信息，默认nil
@property (nonatomic, copy) NSDictionary *userInfo;
/// header
@property (nonatomic, readonly) Class headerClass;
@property (nonatomic, copy, readonly) NSString *headerReuseID;
@property (nonatomic, assign) TPTableSectionHeightBlock headerHeight;
@property (nonatomic, copy) TPTableSectionPreparedBlock headerPrepared;
/// footer
@property (nonatomic, readonly) Class footerClass;
@property (nonatomic, copy, readonly) NSString *footerReuseID;
@property (nonatomic, assign) TPTableSectionHeightBlock footerHeight;
@property (nonatomic, copy) TPTableSectionPreparedBlock footerPrepared;

/// 初始化
+ (instancetype)section;
+ (instancetype)sectionWithID:(id<NSCopying>)sId;

/// 注册sectionHeaderVIew的类
- (void)setHeaderClass:(Class)headerClass;
- (void)setHeaderClass:(Class)headerClass reuserID:(NSString *)identifier;
/// 注册sectionFooterView的类
- (void)setFooterClass:(Class)footerClass;
- (void)setFooterClass:(Class)footerClass reuseID:(NSString *)identifier;
@end

@interface NSArray (TPTableSection)
- (TPTableSection *)TPTableSection;
@end
