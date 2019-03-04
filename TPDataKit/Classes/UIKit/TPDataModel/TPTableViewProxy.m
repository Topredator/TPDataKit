//
//  TPTableViewProxy.m
//  TPKit
//
//  Created by Topredator on 2019/3/4.
//

#import "TPTableViewProxy.h"
#import "TPMultipleProxy.h"
#import <objc/runtime.h>
#import "NSArray+TPSafety.h"
#import "TPDataProxyPrivate.h"

@interface TPTableViewProxy () <TPTableViewProxyPrivate>
@property (nonatomic, strong) TPMultipleProxy *dataSourceProxy;
@property (nonatomic, strong) TPMultipleProxy *delegateProxy;
@property (nonatomic, strong) NSMutableSet *headerFooterClassSet;
@property (nonatomic, strong) NSMutableSet *cellClassSet;
@property (nonatomic, strong) NSMapTable *dataBindingMap;
@end

@implementation TPTableViewProxy
- (void)dealloc {
    [self _TPUnbindAllTableData];
}
+ (instancetype)proxyWithTableView:(UITableView *)tableView {
    return [[self alloc] initWithTableView:tableView];
}
- (instancetype)initWithTableView:(UITableView *)tableView {
    _tableView = tableView;
    _tableView.dataSource = self;
    _tableView.delegate = self;
    return self;
}
- (void)setDataSource:(id<UITableViewDataSource>)dataSource {
    _dataSource = dataSource;
    if (dataSource) {
        self.dataSourceProxy = [TPMultipleProxy proxyWithObjects:@[self, dataSource]];
        self.tableView.dataSource = (id)self.dataSourceProxy;
    } else {
        self.tableView.dataSource = self;
    }
}
- (void)setDelegate:(id<UITableViewDelegate>)delegate {
    _delegate = delegate;
    if (delegate) {
        self.delegateProxy = [TPMultipleProxy proxyWithObjects:@[self, delegate]];
        self.tableView.delegate = (id)self.delegateProxy;
    } else {
        self.tableView.delegate = self;
    }
}
- (void)reloadData:(NSArray<TPTableSection<TPTableRow *> *> *)datas {
    [self _TPUnbindAllTableData];
    _datas = datas;
    [self regitstAllClassForData:datas];
    [self.tableView reloadData];
}
#pragma mark ==================  TPTableViewProxyPrivate   ==================
- (void)_TPBindTableData:(id <TPDataPrivate>)data forView:(__kindof UIView *)view {
    [data _TPBindView:view dataProxy:self];
    [self.dataBindingMap setObject:data forKey:view];
}
- (void)_TPUnbindTableDataForView:(__kindof UIView *)view {
    id <TPDataPrivate> data = [self.dataBindingMap objectForKey:view];
    if (data) {
        [data _TPUnbindVIewWithDataProxy:self];
        [self.dataBindingMap removeObjectForKey:view];
    }
}
- (void)_TPUnbindAllTableData {
    for (id <TPDataPrivate> data in self.dataBindingMap.objectEnumerator) {
        [data _TPUnbindVIewWithDataProxy:self];
    }
    [self.dataBindingMap removeAllObjects];
}
#pragma mark ==================  RegisteClass   ==================
- (void)regitstAllClassForData:(NSArray<TPTableSection<TPTableRow *> *> *)data {
    [self registCellClass:[UITableViewCell class] reuseIdentifier:@"UITableViewCell"];
    for (TPTableSection *section in self.datas) {
        [self registSectionHeaderFooterViewClass:section.headerClass reuseIdentifier:section.headerReuseID];
        [self registSectionHeaderFooterViewClass:section.footerClass reuseIdentifier:section.footerReuseID];
        for (TPTableRow *row in section) {
            [self registCellClass:row.cellClass reuseIdentifier:row.cellReuseID];
        }
    }
}
- (void)registCellClass:(Class)cellClass reuseIdentifier:(NSString *)identifier {
    if (cellClass && ![self.cellClassSet containsObject:identifier]) {
        [self.tableView registerClass:cellClass forCellReuseIdentifier:identifier];
        [self.cellClassSet addObject:identifier];
    }
}
- (void)registSectionHeaderFooterViewClass:(Class)viewClass reuseIdentifier:(NSString *)identifier {
    if (viewClass && ![self.headerFooterClassSet containsObject:identifier]) {
        [self.tableView registerClass:viewClass forHeaderFooterViewReuseIdentifier:identifier];
        [self.headerFooterClassSet addObject:identifier];
    }
}
#pragma mark ==================  NSProxy   ==================
- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector {
    return [self.tableView methodSignatureForSelector:aSelector];
}
- (void)forwardInvocation:(NSInvocation *)anInvocation {
    [anInvocation invokeWithTarget:self.tableView];
}

#pragma mark ==================  UITableView dataSource and delegate  ==================
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.datas count];
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[self.datas tpObjectAtIndex:section] count];
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    TPTableRow *row = [[self.datas tpObjectAtIndex:indexPath.section] tpObjectAtIndex:indexPath.row];
    return [row TPTableVIewCellHeightWithTableViewProxy:self indexPath:indexPath];
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    TPTableSection *data = [self.datas tpObjectAtIndex:section];
    return [data TPTableViewHeaderHeightWithTableViewProxy:self section:section];
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    TPTableSection *data = [self.datas tpObjectAtIndex:section];
    return [data TPTableViewFooterHeightWithTableViewProxy:self section:section];
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    TPTableSection *data = [self.datas tpObjectAtIndex:section];
    if (data.headerClass) {
        NSString *identifier = data.headerReuseID;
        UITableViewHeaderFooterView *view = [tableView dequeueReusableHeaderFooterViewWithIdentifier:identifier];
        [data TPTableViewHeader:view preparedWithTableViewProxy:self section:section];
        return view;
    }
    return nil;
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    TPTableSection *data = [self.datas tpObjectAtIndex:section];
    if (data.footerClass) {
        NSString *identifier = data.footerReuseID;
        UITableViewHeaderFooterView *view = [tableView dequeueReusableHeaderFooterViewWithIdentifier:identifier];
        [data TPTableViewFooter:view preparedWithTableViewProxy:self section:section];
        return view;
    }
    return nil;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TPTableRow *data = [[self.datas tpObjectAtIndex:indexPath.section] tpObjectAtIndex:indexPath.row];
    NSString *identifier = data.cellClass ? data.cellReuseID : @"UITableViewCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    /// 设置proxy属性 是为了在prepareForReuse 的时候需要获取cell所在的indexPath（可能会用到 因为是协议可选方法）
    cell.tableProxy = self;
    /// cell与row进行绑定
    [self _TPBindTableData:(id <TPDataPrivate>)data forView:cell];
    [data TPTableViewPreparedCell:cell tableViewProxy:self indexPath:indexPath];
    return cell;
}
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    TPTableRow *data = [[self.datas tpObjectAtIndex:indexPath.section] tpObjectAtIndex:indexPath.row];
    return [data TPTableViewCanEditRowWithTableViewProxy:self indexPath:indexPath];
}
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    TPTableRow *data = [[self.datas tpObjectAtIndex:indexPath.section] tpObjectAtIndex:indexPath.row];
    [data TPTableViewCommitEditingStyle:editingStyle tableViewProxy:self indexPath:indexPath];
}
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    TPTableRow *data = [[self.datas tpObjectAtIndex:indexPath.section] tpObjectAtIndex:indexPath.row];
    [data TPTableViewWillDisplayCell:cell tableViewProxy:self indexPath:indexPath];
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    TPTableRow *data = [[self.datas tpObjectAtIndex:indexPath.section] tpObjectAtIndex:indexPath.row];
    [data TPTableViewDidSelectedCellWithTableViewProxy:self indexPath:indexPath];
}
#pragma mark ==================  lazy method  ==================
- (NSMutableSet *)headerFooterClassSet {
    if (!_headerFooterClassSet) {
        _headerFooterClassSet = [NSMutableSet set];
    }
    return _headerFooterClassSet;
}
- (NSMutableSet *)cellClassSet {
    if (!_cellClassSet) {
        _cellClassSet = [NSMutableSet set];
    }
    return _cellClassSet;
}
- (NSMapTable *)dataBindingMap {
    if (!_dataBindingMap) {
        _dataBindingMap = [NSMapTable strongToStrongObjectsMapTable];
    }
    return _dataBindingMap;
}
@end


static char kTPProxyKey;
@implementation UITableView (TPTableViewProxy)
- (TPTableViewProxy *)TPProxy {
    return objc_getAssociatedObject(self, &kTPProxyKey);
}
- (void)setTPProxy:(TPTableViewProxy *)TPProxy {
    objc_setAssociatedObject(self, &kTPProxyKey, TPProxy, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
@end

@implementation UIViewController (TPTableViewProxy)
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [tableView.TPProxy tableView:tableView numberOfRowsInSection:section];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [tableView.TPProxy tableView:tableView cellForRowAtIndexPath:indexPath];
}

@end
