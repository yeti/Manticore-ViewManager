//
//  MCTabBar.h
//  Manticore-ViewManager
//
//  Created by Philippe Bertin on 8/18/14.
//  Copyright (c) 2014 Yeti LLC. All rights reserved.
//

#import "MCViewController.h"

@interface MCTabBar : MCViewController <UITabBarDelegate>

@property (weak, nonatomic) IBOutlet UITabBar *tabBar;

@end
