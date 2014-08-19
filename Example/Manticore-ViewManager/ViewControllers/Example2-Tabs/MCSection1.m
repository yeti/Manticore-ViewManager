//
//  MCSection1.m
//  Manticore-ViewManager
//
//  Created by Philippe Bertin on 8/18/14.
//  Copyright (c) 2014 Yeti LLC. All rights reserved.
//

#import "MCSection1.h"

@interface MCSection1 ()

@end

@implementation MCSection1

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
    
    
}

-(void)onResume:(MCActivity *)activity
{
    [super onResume:activity];
    
    [self addChildViewController:[MCAppModel sharedModel].tabBar];
    [self.view addSubview:[MCAppModel sharedModel].tabBar.view];
}




@end
