//
//  MCMainViewController.h
//  Manticore View Manager
//
//  Created by Richard Fung on 1/22/13.
//  Reworked, refactored and commented by Philippe Bertin on August 1, 2014
//  Copyright (c) 2014 Yeti LLC. All rights reserved.
//
// TODO: disable auto power off

#import <UIKit/UIKit.h>
#import "MCSectionViewController.h"
#import "MCErrorViewController.h"
#import "MCConstants.h"

@interface MCMainViewController : MCViewController

// Do we really need to make these readable ?

@property (strong, nonatomic, readonly) NSMutableDictionary *dictCacheView;
@property (strong, nonatomic, readonly) MCErrorViewController* errorVC;
@property (strong, nonatomic, readonly) MCSectionViewController* currentSectionVC;
@property (strong, nonatomic, readonly) MCActivity* activeActivity;
@property (strong, nonatomic, readonly) UIButton* screenOverlayButton;
@property (strong, nonatomic, readonly) NSArray* screenOverlaySlideshow;

@end
