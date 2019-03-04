//
//  TPTableRow.h
//  TPKit
//
//  Created by Topredator on 2019/3/4.
//

#import <Foundation/Foundation.h>
#import "TPModelID.h"

@class TPTableRow;
@class TPTableViewProxy;

typedef CGFloat (^TPTableCellHeightBlock)(__kindof TPTableRow *rowData, TPTableViewProxy *proxy, NSIndexPath *indexPath);
typedef void (^TPTableCellWillDisplayBlock)(__kindof TPTableRow *rowData, TPTableViewProxy *proxy, __kindof UITableViewCell *cell, NSIndexPath *indexPath);
typedef void (^TPTableCellPreparedBlock)(__kindof TPTableRow *row, TPTableViewProxy *proxy, __kindof UITableViewCell *cell, NSIndexPath *indexPath);
typedef void (^TPTableCellDidSelectedBlock)(__kindof TPTableRow *row, TPTableViewProxy *proxy, NSIndexPath *indexPath);
typedef BOOL (^TPTableCellCanEditBlock)(__kindof TPTableRow *row, TPTableViewProxy *proxy, NSIndexPath *indexPath);
typedef void (^TPTableCellCommitEditingBlock)(__kindof TPTableRow *row, TPTableViewProxy *proxy,  UITableViewCellEditingStyle editingStyle, NSIndexPath *indexPath);

@protocol TPTableViewRowDelegate <NSObject>
/// cell 的高
- (CGFloat)TPTableVIewCellHeightWithTableViewProxy:(TPTableViewProxy *)proxy indexPath:(NSIndexPath *)indexPath;
/// cell将要展示
- (void)TPTableViewWillDisplayCell:(__kindof UITableViewCell *)cell tableViewProxy:(TPTableViewProxy *)proxy indexPath:(NSIndexPath *)indexPath;
/// cell 展示
- (void)TPTableViewPreparedCell:(__kindof UITableViewCell *)cell tableViewProxy:(TPTableViewProxy *)proxy indexPath:(NSIndexPath *)indexPath;
/// cell点击
- (void)TPTableViewDidSelectedCellWithTableViewProxy:(TPTableViewProxy *)proxy indexPath:(NSIndexPath *)indexPath;
/// cell是否可编辑
- (BOOL)TPTableViewCanEditRowWithTableViewProxy:(TPTableViewProxy *)proxy indexPath:(NSIndexPath *)indexPath;
/// cell 提交编辑
- (void)TPTableViewCommitEditingStyle:(UITableViewCellEditingStyle)editingStyle tableViewProxy:(TPTableViewProxy *)proxy indexPath:(NSIndexPath *)indexPath;
@optional
/// 重用cell
- (void)TPTableViewWillReuseCell:(__kindof UITableViewCell *)cell tableViewProxy:(TPTableViewProxy *)proxy indexPath:(NSIndexPath *)indexPath;
@end

@interface TPTableRow : NSObject <TPModelID, TPTableViewRowDelegate>
/// 自身可携带信息，默认nill
@property (nonatomic, copy) NSDictionary *userInfo;
/// 注册cell的类
@property (nonatomic, readonly) Class cellClass;
/// cell的重用标识符
@property (nonatomic, copy, readonly) NSString *cellReuseID;
/// 当前显示的cell，当cell被重用时置空
@property (nonatomic, weak, readonly) __kindof UITableViewCell *cell;

@property (nonatomic, assign) TPTableCellHeightBlock cellHeight;
@property (nonatomic, copy) TPTableCellPreparedBlock cellPrepared;
@property (nonatomic, copy) TPTableCellWillDisplayBlock cellWillDisplay;
@property (nonatomic, copy) TPTableCellDidSelectedBlock cellDidSelected;
@property (nonatomic, copy) TPTableCellCanEditBlock cellCanEdit;
@property (nonatomic, copy) TPTableCellCommitEditingBlock cellCommitEdit;


/// 初始化
+ (instancetype)row;
+ (instancetype)rowWithID:(id<NSCopying>)rowId;
- (instancetype)init NS_DESIGNATED_INITIALIZER;
- (instancetype)initWithID:(id<NSCopying>)rowId;

/// 注册cell的类
- (void)setCellClass:(Class)cellClass;
- (void)setCellClass:(Class)cellClass reuseID:(NSString *)reuseID;

/**
 重新渲染cell样式，如果cell未被重用，会触发当前数据源内部的“CKTableViewWillDisplayCell:withTableView:indexPath:”方法
 */
- (void)displayCell;
@end

