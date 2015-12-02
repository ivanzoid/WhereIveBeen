//
//  ViewController.m
//  WhereIveBeen
//
//  Created by Ivan Zezyulya on 24.11.15.
//  Copyright © 2015 Ivan Zezyulya. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
@end

@implementation ViewController {
}

- (void) viewDidLoad
{
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor whiteColor];

    UILabel *label = [UILabel new];
    label.text = @"Working";
    [label sizeToFit];
    label.center = CGPointMake(self.view.bounds.size.width/2, self.view.bounds.size.height/2);
    [self.view addSubview:label];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    self.navigationController.navigationBarHidden = YES;
}

@end
