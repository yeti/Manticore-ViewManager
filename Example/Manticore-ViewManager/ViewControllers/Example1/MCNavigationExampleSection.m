//
//  MCSectionLoginVC.m
//  MCViewManager
//
//  Created by Philippe Bertin on 8/14/14.
//  Copyright (c) 2014 Philippe Bertin. All rights reserved.
//

#import "MCNavigationExampleSection.h"

@interface MCNavigationExampleSection ()
@property (weak, nonatomic) IBOutlet UIView *navigationView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *heightConstraint;

@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UIButton *backButton;

@end

@implementation MCNavigationExampleSection

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

// You may implement the method onResume if needed. It is called when the View is about to be shown.
// A section's onResume is always called before its Views onResume.
-(void)onResume:(MCActivity *)activity
{
    if (![[MCViewManager sharedManager] isCurrentViewRootInSection])
        _backButton.hidden = false;
    else
        _backButton.hidden = true;
    
    // DO NOT FORGET to transmit onResume to super
    [super onResume:activity];
    
    // All the things to make example nice
    [self dealWithExample];
    
}


- (IBAction)backButtonPressed:(id)sender
{
    if (![[MCViewManager sharedManager] isCurrentViewRootInSection])
    {
        MCIntent *intent = [MCIntent intentPopToActivityInHistoryByPositionLast];
        intent.transitionAnimationStyle = ANIMATION_POP;
        [[MCViewManager sharedManager] processIntent:intent];
    }
}

// All the things for example purpose
-(void)dealWithExample
{
    if ([MCViewManager sharedManager].activityStackCount == 2)
    {
        [self.view layoutIfNeeded];
        _textView.text = nil;
        [UIView animateWithDuration:0.5 animations:^{
            _heightConstraint.constant = 70;
            [self.view layoutIfNeeded];
        }];
    }
    
    if ([MCViewManager sharedManager].activityStackCount == 4)
    {
        [self.view layoutIfNeeded];
        [UIView animateWithDuration:0.5 animations:^{
            _heightConstraint.constant = 150;
            [self.view layoutIfNeeded];
        } completion:^(BOOL finished) {
            _textView.text = @"Now you are going to \"POP\" to the last Activity by pressing the \"Back button\". Because the View has already been loaded by Manticore (you did not clear the ViewCache) the text you entered will still be there (unless you clean the UI with \"onResume\" or with the usual \"viewDidAppear\" method).";
        }];
        
        
    }
}

@end
