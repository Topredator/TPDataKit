//
//  TPViewController.m
//  TPDataKit
//
//  Created by Topredator on 03/04/2019.
//  Copyright (c) 2019 Topredator. All rights reserved.
//

#import "TPViewController.h"

#import "TextRow.h"
#import "TestViewController.h"



@interface TPViewController ()
@property (strong, nonatomic) IBOutlet UITableView *myTable;
@end

@implementation TPViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.myTable.TPProxy = [TPTableViewProxy proxyWithTableView:self.myTable];
    [self reloadData];
}
- (void)reloadData {
    TPTableSection *section = [TPTableSection section];
    for (int i = 0; i < 15; i++) {
        TextRow *row = [TextRow row];
        row.text = [NSString stringWithFormat:@"第%d行", i + 1];
        row.cellDidSelected = ^(TextRow *rowData, TPTableViewProxy *proxy, NSIndexPath *indexPath) {
            [proxy.tableView deselectRowAtIndexPath:indexPath animated:YES];
            if (indexPath.row == 14) {
                TestViewController *testVC = [TestViewController new];
                [self.navigationController pushViewController:testVC animated:YES];
                return;
            }
            int count = [rowData.userInfo[@"count"] intValue];
            rowData.text = [NSString stringWithFormat:@"第%d行 --%d", i + 1, ++count];
            rowData.userInfo = @{@"count": @(count)};
        };
        [section addObject:row];
    }
    [self.myTable.TPProxy reloadData:@[section]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
