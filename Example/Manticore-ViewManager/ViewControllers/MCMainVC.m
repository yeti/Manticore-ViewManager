//
//  MCMainVC.m
//  MCViewManager
//
//  Created by Philippe Bertin on 8/13/14.
//  Copyright (c) 2014 Philippe Bertin. All rights reserved.
//

#import "MCMainVC.h"


@interface MCMainVC ()

@end

@implementation MCMainVC

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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)welcomeButtonPressed:(id)sender
{
    MCIntent *intent = [MCIntent intentNewActivityWithAssociatedViewNamed:VIEW_NAVIGATION_1     inSectionNamed:SECTION_1_NAVIGATION];
    [[MCViewManager sharedManager] processIntent:intent];
}

@end
