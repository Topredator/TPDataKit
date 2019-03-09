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
@interface TestViewController ()
@property (nonatomic, strong) TPPerson *person;
@end

@implementation TestViewController
- (void)dealloc {
//    [self.person TPRemoveObserverForKeyPath:@"name"];
//    [self.person TPRemoveObserverForKeyPath:@"age"];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.whiteColor;
    self.tpNavigationItem.navigationBarHidden = YES;
    
    self.person = [TPPerson new];
//    self.person.tpIgnoreDuplicateValues = YES;
    [self.person TPAddObserverForKeyPath:@"name" options:TPObservingChangeOptionsOld | TPObservingChangeOptionsNew block:^(NSObject *obj, NSString *keyPath, NSDictionary *change) {
        NSLog(@"object = %@, keyPath = %@, change = %@", obj, keyPath, change);
    }];
    [self.person TPAddObserverForKeyPath:@"age" options:TPObservingChangeOptionsOld | TPObservingChangeOptionsNew block:^(NSObject *obj, NSString *keyPath, NSDictionary *change) {
        NSLog(@"object = %@, keyPath = %@, change = %@", obj, keyPath, change);
    }];
//    [self.person TPRemoveObserverForKeyPath:@"age"];
    [self.person TPAddObserverForKeyPath:@"rect" options:TPObservingChangeOptionsOld | TPObservingChangeOptionsNew block:^(NSObject *obj, NSString *keyPath, NSDictionary *change) {
        NSLog(@"object = %@, keyPath = %@, change = %@", obj, keyPath, change);
    }];
    self.person.name = @"Topredator";
    self.person.name = @"Top";
    
    self.person.age = 11;
    self.person.age = 12;
    
    self.person.rect = CGRectMake(0, 0, 10, 10);
    self.person.rect = CGRectMake(1, 1, 11, 11);
}
@end
