//
//  MCViewController.m
//  Manticore iOSViewFactory
//
//  Created by Richard Fung on 9/19/12.
//  Copyright (c) 2014 Yeti LLC. All rights reserved.
//

#import "MCViewController.h"

@implementation MCViewController

@synthesize debugTag;

-(void)onCreate{
  
}

-(void)onResume:(MCActivity*)activity
{
  self.debugTag = YES;
}

-(void)onPause:(MCActivity*)activity
{
  self.debugTag = YES;
}

@end
