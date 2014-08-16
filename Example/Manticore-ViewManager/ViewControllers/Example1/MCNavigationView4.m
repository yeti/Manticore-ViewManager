//
//  MCNavigationView4.m
//  Manticore-ViewManager
//
//  Created by Philippe Bertin on 8/15/14.
//  Copyright (c) 2014 Yeti LLC. All rights reserved.
//

#import "MCNavigationView4.h"

@interface MCNavigationView4 ()

@property (weak, nonatomic) MCActivity *delegateActivity;

@end

@implementation MCNavigationView4

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


-(void)onResume:(MCActivity *)activity
{
    _delegateActivity = [activity.activityInfos objectForKey:@"previousActivity"];
    
    // Finish here : put some info in the activity's dictionary
    
    
    [super onResume:activity];
}

@end
