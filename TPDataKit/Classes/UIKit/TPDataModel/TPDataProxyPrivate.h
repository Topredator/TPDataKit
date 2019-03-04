//
//  TPDataProxyPrivate.h
//  TPKit
//
//  Created by Topredator on 2019/3/4.
//

#import <Foundation/Foundation.h>
#import "TPDataPrivate.h"

@class TPTableRow;
@class TPTableViewProxy;
/// TableVIewProxy 需要的协议  让datau与UIx进行绑定
@protocol TPTableViewProxyPrivate <TPDataProxyPrivate>
- (void)_TPBindTableData:(id <TPDataPrivate>)data forView:(__kindof UIView *)view;
- (void)_TPUnbindTableDataForView:(__kindof UIView *)view;
- (void)_TPUnbindAllTableData;
@end

@interface UITableViewCell (TPTableDataPrivate)
@property (nonatomic, strong) TPTableViewProxy <TPTableViewProxyPrivate> *tableProxy;
- (void)_TPDisplayTableData:(TPTableRow *)data;
@end
