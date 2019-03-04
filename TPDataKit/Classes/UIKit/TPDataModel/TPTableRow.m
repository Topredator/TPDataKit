//
//  TPTableRow.m
//  TPKit
//
//  Created by Topredator on 2019/3/4.
//

#import "TPTableRow.h"
#import "TPDataPrivate.h"
#import "TPDataProxyPrivate.h"
#import "TPTableViewProxy.h"

@interface TPTableRow () <TPDataPrivate>
@property (nonatomic, copy) id mIdentity;
@end

@implementation TPTableRow
+ (instancetype)row {
    return [[self alloc] init];
}
+ (instancetype)rowWithID:(id<NSCopying>)rowId {
    return [[self alloc] initWithID:rowId];
}
- (instancetype)init {
    self = [super init];
    return self;
}
- (instancetype)initWithID:(id<NSCopying>)rowId {
    self = [self init];
    if (!self) return nil;
    self.mIdentity = rowId;
    return self;
}
- (id)modelID {
    return self.mIdentity;
}
- (void)setCell:(__kindof UITableViewCell *)cell {
    _cell = cell;
}

- (void)setCellClass:(Class)cellClass {
    [self setCellClass:cellClass reuseID:nil];
}
- (void)setCellClass:(Class)cellClass reuseID:(NSString *)reuseID {
    _cellClass = cellClass;
    _cellReuseID = reuseID ?: NSStringFromClass(cellClass);
}
- (void)displayCell {
    [self.cell _TPDisplayTableData:self];
}
#pragma mark ==================  TPTableViewRowDelegate   ==================
/// cell 的高
- (CGFloat)TPTableVIewCellHeightWithTableViewProxy:(TPTableViewProxy *)proxy indexPath:(NSIndexPath *)indexPath {
    if (self.cellHeight) {
        return self.cellHeight(self, proxy, indexPath);
    }
    return UITableViewAutomaticDimension;
}
/// cell将要展示
- (void)TPTableViewWillDisplayCell:(__kindof UITableViewCell *)cell tableViewProxy:(TPTableViewProxy *)proxy indexPath:(NSIndexPath *)indexPath {
    if (self.cellWillDisplay) {
        self.cellWillDisplay(self, proxy, cell, indexPath);
    }
}
/// cell 展示
- (void)TPTableViewPreparedCell:(__kindof UITableViewCell *)cell tableViewProxy:(TPTableViewProxy *)proxy indexPath:(NSIndexPath *)indexPath {
    if (self.cellPrepared) {
        self.cellPrepared(self, proxy, cell, indexPath);
    }
}
/// cell点击
- (void)TPTableViewDidSelectedCellWithTableViewProxy:(TPTableViewProxy *)proxy indexPath:(NSIndexPath *)indexPath {
    if (self.cellDidSelected) {
        self.cellDidSelected(self, proxy, indexPath);
    }
}
/// cell是否可编辑
- (BOOL)TPTableViewCanEditRowWithTableViewProxy:(TPTableViewProxy *)proxy indexPath:(NSIndexPath *)indexPath {
    if (self.cellCanEdit) {
        return self.cellCanEdit(self, proxy, indexPath);
    }
    return NO;
}
/// cell 提交编辑
- (void)TPTableViewCommitEditingStyle:(UITableViewCellEditingStyle)editingStyle tableViewProxy:(TPTableViewProxy *)proxy indexPath:(NSIndexPath *)indexPath {
    if (self.cellCommitEdit) {
        self.cellCommitEdit(self, proxy, editingStyle, indexPath);
    }
}
#pragma mark ==================  TPDataPrivate   ==================
- (void)_TPBindView:(__kindof UIView *)view dataProxy:(TPTableViewProxy <TPTableViewProxyPrivate> *)proxy {
    if (self.cell) {
        [proxy _TPUnbindTableDataForView:self.cell];
    }
    self.cell = view;
}
- (void)_TPUnbindVIewWithDataProxy:(id <TPDataProxyPrivate>)proxy {
    self.cell = nil;
}
@end
