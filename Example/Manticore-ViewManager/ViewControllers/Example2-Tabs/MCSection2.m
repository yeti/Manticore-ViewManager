//
//  MCSection2.m
//  Manticore-ViewManager
//
//  Created by Philippe Bertin on 8/18/14.
//  Copyright (c) 2014 Yeti LLC. All rights reserved.
//

#import "MCSection2.h"

@interface MCSection2 ()

@end

@implementation MCSection2

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

-(void)onResume:(MCActivity *)activity
{
    [super onResume:activity];
    
    [self addChildViewController:[MCAppModel sharedModel].tabBar];
    [self.view addSubview:[MCAppModel sharedModel].tabBar.view];
}

@end
