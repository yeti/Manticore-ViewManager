//
//  MCWelcomeVC.m
//  MCViewManager
//
//  Created by Philippe Bertin on 8/14/14.
//  Copyright (c) 2014 Philippe Bertin. All rights reserved.
//

#import "MCNavigationView2.h"

@interface MCNavigationView2 ()

@property (weak, nonatomic) IBOutlet UITextField *textInputField;

@end

@implementation MCNavigationView2

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
    // Clean the UI
    //_textInputField.text = nil;
    
    [super onResume:activity];
}



- (IBAction)transmitButtonPressed:(id)sender
{
    NSString *inputText;
    
    if (_textInputField.text.length)
        inputText = _textInputField.text;
    else
        inputText = @"You did not type anything !";
    
    MCIntent *intent = [MCIntent intentNewActivityWithAssociatedViewNamed:VIEW_NAVIGATION_3
                                                           inSectionNamed:SECTION_1_NAVIGATION];
    // Se the animation for transition
    [intent setTransitionAnimationStyle:ANIMATION_PUSH];
    
    // Set any kind of Data here :
    [intent.userInfos setValue:inputText forKey:@"inputText"];
    
    // Process intent
    [[MCViewManager sharedManager] processIntent:intent];
}

@end
