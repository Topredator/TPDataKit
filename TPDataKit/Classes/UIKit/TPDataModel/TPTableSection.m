//
//  TPTableSection.m
//  TPKit
//
//  Created by Topredator on 2019/3/4.
//

#import "TPTableSection.h"

@implementation TPTableSection
+ (instancetype)section {
    return [[self alloc] initWithID:nil];
}
+ (instancetype)sectionWithID:(id<NSCopying>)sId {
    return [[self alloc] initWithID:sId];
}
- (void)setHeaderClass:(Class)headerClass {
    [self setHeaderClass:headerClass reuserID:nil];
}
- (void)setHeaderClass:(Class)headerClass reuserID:(NSString *)identifier {
    _headerClass = headerClass;
    _headerReuseID = identifier ?: NSStringFromClass(headerClass);
}
- (void)setFooterClass:(Class)footerClass {
    [self setFooterClass:footerClass reuseID:nil];
}
- (void)setFooterClass:(Class)footerClass reuseID:(NSString *)identifier {
    _footerClass = footerClass;
    _footerReuseID = identifier ?: NSStringFromClass(footerClass);
}

#pragma mark ==================  TPTableViewSectionDelegate   ==================
- (CGFloat)TPTableViewHeaderHeightWithTableViewProxy:(TPTableViewProxy *)proxy section:(NSUInteger)section {
    if (self.headerHeight) {
        return self.headerHeight(self, proxy, section);
    }
    return UITableViewAutomaticDimension;
}
- (CGFloat)TPTableViewFooterHeightWithTableViewProxy:(TPTableViewProxy *)proxy section:(NSUInteger)section {
    if (self.footerHeight) {
        return self.footerHeight(self, proxy, section);
    }
    return UITableViewAutomaticDimension;
}
- (void)TPTableViewHeader:(__kindof UITableViewHeaderFooterView *)header preparedWithTableViewProxy:(TPTableViewProxy *)proxy section:(NSUInteger)section {
    if (self.headerPrepared) {
        self.headerPrepared(self, proxy, header, section);
    }
}
- (void)TPTableViewFooter:(__kindof UITableViewHeaderFooterView *)footer preparedWithTableViewProxy:(TPTableViewProxy *)proxy section:(NSUInteger)section {
    if (self.footerPrepared) {
        self.footerPrepared(self, proxy, footer, section);
    }
}
@end

@implementation NSArray (TPTableSection)
- (TPTableSection *)TPTableSection {
    return [[TPTableSection alloc] initWithArray:self];
}

@end
