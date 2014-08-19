//
//  MCAppModel.h
//  MCViewManager
//
//  Created by Philippe Bertin on 8/13/14.
//  Copyright (c) 2014 Philippe Bertin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ManticoreViewManager.h"
#import "MCTabBar.h"

#define VIEW_MAIN @"MCMainVC"

// Example 1 : Navigation
#define SECTION_1_NAVIGATION @"MCNavigationExampleSection"
#define VIEW_NAVIGATION_1 @"MCNavigationView1"
#define VIEW_NAVIGATION_2 @"MCNavigationView2"
#define VIEW_NAVIGATION_3 @"MCNavigationView3"
#define VIEW_NAVIGATION_4 @"MCNavigationView4"

// Example 2 : TabApp
#define SECTION_Tab1 @"MCSection1"
#define SECTION_Tab2 @"MCSection2"
#define VIEW_1_Tab1 @"MCView1Sect1"
#define VIEW_1_Tab2 @"MCView1Sect2"
#define TAB_VIEW @"MCTabBar"


@interface MCAppModel : NSObject

@property (strong, nonatomic) MCTabBar *tabBar;



+ (MCAppModel*)sharedModel;

@end
