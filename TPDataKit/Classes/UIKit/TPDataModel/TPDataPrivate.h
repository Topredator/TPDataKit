//
//  TPDataPrivate.h
//  TPKit
//
//  Created by Topredator on 2019/3/4.
//

#import <Foundation/Foundation.h>

/// proxy需要执行的协议
@protocol TPDataProxyPrivate <NSObject>
- (NSMapTable *)dataBindingMap;
@end

/// 数据的协议 通过proxy 把data与UI进行绑定
@protocol TPDataPrivate <NSObject>
- (void)_TPBindView:(__kindof UIView *)view dataProxy:(id <TPDataProxyPrivate>)proxy;
- (void)_TPUnbindVIewWithDataProxy:(id <TPDataProxyPrivate>)proxy;
@end
