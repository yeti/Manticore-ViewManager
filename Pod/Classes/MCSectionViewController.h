//
//  MCSectionViewController.h
//  Manticore iOSViewFactory
//
//  Created by Richard Fung on 2/7/13.
//  Copyright (c) 2014 Yeti LLC. All rights reserved.
//

#import "MCViewController.h"

@interface MCSectionViewController : MCViewController{
  // The following two variables didViewLoad and showThisView should only be used by MCMainViewController
  // to load the VIEW_*** for SECTION_***. Two cases:
  //
  // 1.  The first time the view is loaded, the IBOutlets from the nib
  //     file aren't loaded yet. viewDidLoad is a deferred load after the IBOutlets are assigned.
  //     Then, we are able to show the VIEW_***.
  //
  // 2.  onResume will check to see if the view has been loaded before, in which case the view can be
  //     loaded immediately and we know that viewDidLoad won't be called again. showThisView will
  //     be unassigned immediately after onResume.
  //
  
}

@property(nonatomic, retain) IBOutlet UIView* innerView;
@property(nonatomic, retain) MCViewController* currentViewVC;

@end
