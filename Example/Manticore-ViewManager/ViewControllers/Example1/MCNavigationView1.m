//
//  MCNavigationView1.m
//  Manticore-ViewManager
//
//  Created by Philippe Bertin on 8/15/14.
//  Copyright (c) 2014 Yeti LLC. All rights reserved.
//

#import "MCNavigationView1.h"

@interface MCNavigationView1 ()

@end

@implementation MCNavigationView1

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


- (IBAction)buttonToView2:(id)sender {
    
    MCIntent *intent = [MCIntent intentNewActivityWithAssociatedViewNamed:VIEW_NAVIGATION_2
                                                           inSectionNamed:SECTION_1_NAVIGATION];
    [intent setTransitionAnimationStyle:ANIMATION_PUSH];
    [[MCViewManager sharedManager] processIntent:intent];
}

@end
