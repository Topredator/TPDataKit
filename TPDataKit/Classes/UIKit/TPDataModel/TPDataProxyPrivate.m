//
//  TPDataProxyPrivate.m
//  TPKit
//
//  Created by Topredator on 2019/3/4.
//

#import "TPDataProxyPrivate.h"
#import "TPTableRow.h"
#import "TPTableViewProxy.h"
#import <objc/runtime.h>
#import "TPUtils.h"

static char kTPTableProxyKey;
@implementation UITableViewCell (TPTableDataPrivate)
+ (void)load {
    TPInstanceMethodSwizzling(self, @selector(prepareForReuse), @selector(_tp_prepareForReuse));
}
- (void)_tp_prepareForReuse {
    TPTableRow *row = [self.tableProxy.dataBindingMap objectForKey:self];
    if (row && [row respondsToSelector:@selector(TPTableViewWillReuseCell:tableViewProxy:indexPath:)]) {
        NSIndexPath *indexPath = [self.tableProxy.tableView indexPathForCell:self];
        [row TPTableViewWillReuseCell:self tableViewProxy:self.tableProxy indexPath:indexPath];
    }
    [self.tableProxy _TPUnbindTableDataForView:self];
    [self _tp_prepareForReuse];
}
- (void)setTableProxy:(TPTableViewProxy<TPTableViewProxyPrivate> *)tableProxy {
    objc_setAssociatedObject(self, &kTPTableProxyKey, tableProxy, OBJC_ASSOCIATION_ASSIGN);
}
- (TPTableViewProxy<TPTableViewProxyPrivate> *)tableProxy {
    return objc_getAssociatedObject(self, &kTPTableProxyKey);
}
- (void)_TPDisplayTableData:(TPTableRow *)data {
    UITableView *tableView = self.tableProxy.tableView;
    if (tableView.delegate && [tableView.delegate respondsToSelector:@selector(tableView:willDisplayCell:forRowAtIndexPath:)]) {
        NSIndexPath *indexPath = [tableView indexPathForCell:self];
        [tableView.delegate tableView:tableView willDisplayCell:self forRowAtIndexPath:indexPath];
    }
}
@end
