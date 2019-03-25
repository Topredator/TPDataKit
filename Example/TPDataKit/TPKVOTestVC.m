//
//  TPKVOTestVC.m
//  TPDataKit_Example
//
//  Created by Topredator on 2019/3/24.
//  Copyright © 2019 Topredator. All rights reserved.
//

#import "TPKVOTestVC.h"
#import "TPPerson.h"


@interface TPKVOTestVC ()
@property (nonatomic, strong) TPPerson *person;
@end

@implementation TPKVOTestVC
- (void)dealloc {
    [self.person TPRemoveObserver:self keyPath:@"name"];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"testtest" object:nil];
}
- (instancetype)initWithPerson:(TPPerson *)person {
    self = [super init];
    if (self) {
        self.person = person;
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    [self.person TPAddObserver:self keyPath:@"name" options:TPObservingChangeOptionsNew | TPObservingChangeOptionsOld block:^(NSObject *obj, NSString *keyPath, NSDictionary *change) {
        NSLog(@"object = %@, keyPath = %@, change = %@", obj, keyPath, change);
    }];
    self.person.name = @"kvo";
}
@end
