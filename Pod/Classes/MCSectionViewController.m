//
//  MCSectionViewController.m
//  Manticore View Manager
//
//  Created by Richard Fung on 2/7/13.
//  Copyright (c) 2014 Yeti LLC. All rights reserved.
//

#import "MCSectionViewController.h"
#import "MCViewManager.h"

@interface MCSectionViewController ()

@end

@implementation MCSectionViewController

@synthesize innerView;
@synthesize currentViewVC;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
  
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


-(void)onCreate
{
    [super onCreate];
}


-(void)onResume:(MCActivity *)activity
{
  [super onResume:activity];
  
  if (currentViewVC) {
    [currentViewVC onResume:activity];
  }
}

-(void)onPause:(MCActivity *)activity
{
    if (currentViewVC){
        [currentViewVC onPause:activity];
    }
    
    [super onPause:activity];
}

@end
