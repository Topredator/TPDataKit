//
//  TPTableViewProxy.h
//  TPKit
//
//  Created by Topredator on 2019/3/4.
//

#import <Foundation/Foundation.h>
#import "TPTableRow.h"
#import "TPTableSection.h"

@interface TPTableViewProxy : NSObject <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, weak, readonly) UITableView *tableView;
@property (nonatomic, weak) id <UITableViewDataSource> dataSource;
@property (nonatomic, weak) id <UITableViewDelegate> delegate;
@property (nonatomic, strong, readonly) NSArray <TPTableSection <TPTableRow *>*> *datas;
/// 初始化
+ (instancetype)proxyWithTableView:(UITableView *)tableView;
- (instancetype)init NS_UNAVAILABLE;
/**
 初始化方法，会赋值tableView的Delegate及DataSource到当前Proxy
 */
- (instancetype)initWithTableView:(UITableView *)tableView;

/**
 重新加载数据，会强制赋值tableView的Delegate及DataSource为当前Proxy
 */
- (void)reloadData:(NSArray <TPTableSection <TPTableRow *>*>*)datas;
@end

@interface UITableView (TPTableViewProxy)
@property (nonatomic, strong) TPTableViewProxy *TPProxy;
@end

@interface UIViewController (TPTableViewProxy)
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
@end
