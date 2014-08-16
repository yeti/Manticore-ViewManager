//
//  MCNavigationView3.m
//  Manticore-ViewManager
//
//  Created by Philippe Bertin on 8/15/14.
//  Copyright (c) 2014 Yeti LLC. All rights reserved.
//

#import "MCNavigationView3.h"

@interface MCNavigationView3 ()

@property (weak, nonatomic) IBOutlet UILabel *labelSection;
@property (weak, nonatomic) IBOutlet UILabel *labelView;
@property (weak, nonatomic) IBOutlet UILabel *labelTextInput;


// You want to keep a weak pointer because MCViewManager owns it.
@property (weak, nonatomic) MCActivity *currentAssociatedActivity;

@end

@implementation MCNavigationView3

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
    // Implement this method that will be called when An activity associated with this View is called by MCViewManager
    
    // The activity contains :
    
    // The associated Section
    NSString *section = activity.associatedSectionName;
    
    // The associated View
    NSString *view = activity.associatedViewName;
    
    // The data associated with the activity (data added in the intent's userInfo is added to the Activity's infos.
    NSDictionary *activityData = activity.activityInfos;
    
    
    // Update UI with the given information
    _labelSection.text = section;
    _labelView.text = view;
    _labelTextInput.text = activityData[@"inputText"];
    
    [super onResume:activity];
    
    
    // See View4 why we do this
    _currentAssociatedActivity = activity;
}

- (IBAction)continueButtonPressed:(id)sender
{
    MCIntent *intent = [MCIntent intentNewActivityWithAssociatedViewNamed:VIEW_NAVIGATION_4
                                                           inSectionNamed:SECTION_1_NAVIGATION];
    // Se the animation for transition
    [intent setTransitionAnimationStyle:ANIMATION_PUSH];
    
    //See View4 why : so set some data from the future Activity to current one
    [[intent userInfos] setObject:_currentAssociatedActivity forKey:@"previousActivity"];
    
    // Process intent
    [[MCViewManager sharedManager] processIntent:intent];
}

@end
