//
//  MCTabBar.m
//  Manticore-ViewManager
//
//  Created by Philippe Bertin on 8/18/14.
//  Copyright (c) 2014 Yeti LLC. All rights reserved.
//

#import "MCTabBar.h"

@interface MCTabBar ()

@property (weak, nonatomic) IBOutlet UITabBarItem *favoriteItem;
@property (weak, nonatomic) IBOutlet UITabBarItem *moreItem;

@end

@implementation MCTabBar

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
    _tabBar.delegate = self;
    _tabBar.selectedItem = _favoriteItem;
}


-(void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item
{
    [[MCViewManager sharedManager] clearActivityStack];
    
    if (item == _favoriteItem)
    {
        
        [[MCViewManager sharedManager] processIntent:[MCIntent intentNewActivityWithAssociatedViewNamed:VIEW_1_Tab1 inSectionNamed:SECTION_Tab1]];
    }
    
    
    if (item == _moreItem)
    {
        [[MCViewManager sharedManager] processIntent:[MCIntent intentNewActivityWithAssociatedViewNamed:VIEW_1_Tab2 inSectionNamed:SECTION_Tab2]];
    }
}


@end
