//
//  MCAppModel.m
//  MCViewManager
//
//  Created by Philippe Bertin on 8/13/14.
//  Copyright (c) 2014 Philippe Bertin. All rights reserved.
//

#import "MCAppModel.h"


@implementation MCAppModel

+ (MCAppModel*)sharedModel
{
    static MCAppModel *sharedModel = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedModel = [[self alloc] init];
    });
    return sharedModel;
}


-(id)init
{
    if (self = [super init])
    {
        _tabBar = (MCTabBar *)[[MCViewManager sharedManager] createViewController:TAB_VIEW];
        
    
        
        NSLog(@"%@", NSStringFromCGRect(_tabBar.view.frame));
        
        
        CGRect tabFrame = _tabBar.view.frame;
        tabFrame.origin.y = [UIScreen mainScreen].bounds.size.height - _tabBar.view.frame.size.height;
        _tabBar.view.frame = tabFrame;
        NSLog(@"%@", NSStringFromCGRect(_tabBar.view.frame));
        
    }
    return self;
}


@end
