//
//  TestViewController.m
//  TPDataKit_Example
//
//  Created by Topredator on 2019/3/4.
//  Copyright © 2019 Topredator. All rights reserved.
//

#import "TestViewController.h"
#import "TPPerson.h"

#import "NSObject+TPCustomKVO.h"
#import "TPKVOTestVC.h"


@interface TestViewController ()
@property (nonatomic, strong) TPPerson *person;
@end

@implementation TestViewController
- (void)dealloc {
    [self.person TPRemoveObserver:self keyPath:@"name"];
    [self.person TPRemoveObserver:self keyPath:@"age"];
    [self.person TPRemoveObserver:self keyPath:@"rect"];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"测试kvo";
    self.view.backgroundColor = UIColor.whiteColor;
    self.person = [TPPerson new];
    self.person.tpIgnoreDuplicateValues = YES;
    
    [self.person TPAddObserver:self keyPath:@"name" options:TPObservingChangeOptionsOld | TPObservingChangeOptionsNew block:^(NSObject *obj, NSString *keyPath, NSDictionary *change) {
        NSLog(@"object = %@, keyPath = %@, change = %@", obj, keyPath, change);
    }];
    [self.person TPAddObserver:self keyPath:@"age" options:TPObservingChangeOptionsOld | TPObservingChangeOptionsNew block:^(NSObject *obj, NSString *keyPath, NSDictionary *change) {
        NSLog(@"object = %@, keyPath = %@, change = %@", obj, keyPath, change);
    }];
    [self.person TPAddObserver:self keyPath:@"rect" options:TPObservingChangeOptionsOld | TPObservingChangeOptionsNew block:^(NSObject *obj, NSString *keyPath, NSDictionary *change) {
        NSLog(@"object = %@, keyPath = %@, change = %@", obj, keyPath, change);
    }];
    self.person.name = @"Topredator";
    self.person.name = @"Top";
    
    self.person.age = 11;
    self.person.age = 12;
    
    self.person.rect = CGRectMake(0, 0, 10, 10);
    self.person.rect = CGRectMake(1, 1, 11, 11);
    
    
    __weak typeof(self) weakSelf = self;
    /// tap点击
    [self.view TPTapActionWithBlock:^{
        TPKVOTestVC *vc = [[TPKVOTestVC alloc] initWithPerson:weakSelf.person];
        [weakSelf.navigationController pushViewController:vc animated:YES];
    }];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(haha:) name:@"testtest" object:nil];
}
- (void)haha:(NSNotification *)notify {
    self.person.name = @"kvo1111";
}

@end
