//
//  TextRow.m
//  TPDataKit_Example
//
//  Created by Topredator on 2019/3/4.
//  Copyright © 2019 Topredator. All rights reserved.
//

#import "TextRow.h"

@implementation TextRow
- (void)setText:(NSString *)text {
    _text = text;
    [self displayCell];
}

- (CGFloat)TPTableVIewCellHeightWithTableViewProxy:(TPTableViewProxy *)proxy indexPath:(NSIndexPath *)indexPath {
    return 50;
}
- (void)TPTableViewWillDisplayCell:(UITableViewCell *)cell tableViewProxy:(TPTableViewProxy *)proxy indexPath:(NSIndexPath *)indexPath {
    cell.textLabel.text = self.text;
}
@end
