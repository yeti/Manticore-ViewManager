//
//  MCMainViewController.m
//  Manticore View Manager
//
//  Created by Richard Fung on 1/22/13.
//  Reworked, refactored and commented by Philippe Bertin on August 1, 2014
//  Copyright (c) 2014 Yeti LLC. All rights reserved.
//


#import "MCViewController.h"
#import "MCErrorViewController.h"
#import "MCMainViewController.h"
#import "MCSectionViewController.h"
#import "MCViewManager.h"
#import "MCActivity.h"




// this function taken from http://stackoverflow.com/questions/10330679/how-to-dispatch-on-main-queue-synchronously-without-a-deadlock
void manticore_runOnMainQueueWithoutDeadlocking(void (^block)(void))
{
  if ([NSThread isMainThread])
  {
    block();
  }
  else
  {
    dispatch_sync(dispatch_get_main_queue(), block);
  }
}




@interface MCMainViewController ()

@property (strong, nonatomic, readwrite) NSMutableDictionary *dictCacheView;
@property (strong, nonatomic, readwrite) MCErrorViewController* errorVC;
@property (strong, nonatomic, readwrite) MCSectionViewController* currentSectionVC;
@property (strong, nonatomic, readwrite) MCActivity* activeActivity;
@property (strong, nonatomic, readwrite) UIButton* screenOverlayButton;
@property (strong, nonatomic, readwrite) NSArray* screenOverlaySlideshow;

@end

@implementation MCMainViewController


/* 
 *
 * Register listeners to repsond to MCViewManager changes
 *
 */
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        // register to listeners on model changes
        [[MCViewManager sharedManager] addObserver:self forKeyPath:@"currentActivity" options: NSKeyValueObservingOptionNew context: nil];
        [[MCViewManager sharedManager] addObserver:self forKeyPath:@"errorDict" options: NSKeyValueObservingOptionNew context: nil];
        [[MCViewManager sharedManager] addObserver:self forKeyPath:@"screenOverlay" options: NSKeyValueObservingOptionNew context: nil];
        [[MCViewManager sharedManager] addObserver:self forKeyPath:@"screenOverlays" options: NSKeyValueObservingOptionNew context: nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(flushViewCache:) name:@"MCMainViewController_flushViewCache" object:[MCViewManager sharedManager]];
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
  
    _dictCacheView = [NSMutableDictionary dictionaryWithCapacity:10];
}

/*
 * Selector called when MCViewManager flushViewCache's method is called.
 *
 */
-(void)flushViewCache:(NSNotification *)notification
{
    _dictCacheView = [NSMutableDictionary dictionaryWithCapacity:10];
}


/*!
 * Observed values from MCViewManager :
 *
 * - currentActivity
 * - errorDict
 * - screenOverlay
 * - screenOverlays
 *
 */
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"currentActivity"])
    {
        manticore_runOnMainQueueWithoutDeadlocking(^{
            [self updateUIWithNewActivity:[object valueForKeyPath:keyPath]];
        });
    
    } else if ([keyPath isEqualToString:@"errorDict"])
    {
        manticore_runOnMainQueueWithoutDeadlocking(^{
            if (!_errorVC)
            {
#warning deal with custom error controllers
                _errorVC = (MCErrorViewController*) [[MCViewManager sharedManager] createViewController:VIEW_BUILTIN_ERROR];
            }
            
            // remove from the previous
            [_errorVC.view removeFromSuperview];
            [_errorVC removeFromParentViewController];

            // set up
            [_errorVC loadLatestErrorMessageWithDictionary:[object valueForKeyPath:keyPath]];

            // add to the current
            [_errorVC.view setFrame:[self.view bounds]];
            [self.view addSubview: _errorVC.view];

            [_currentSectionVC.currentViewVC.view resignFirstResponder];
            [_currentSectionVC.view resignFirstResponder];


            [_errorVC becomeFirstResponder]; // make the error dialog the first responder
          
        });
  
    } else if ([keyPath isEqualToString:@"screenOverlay"])
    {
        manticore_runOnMainQueueWithoutDeadlocking(^{
          
            [self overlaySlideshow:@[[MCViewManager sharedManager].screenOverlay]];
            
        });
      
    } else if ([keyPath isEqualToString:@"screenOverlays"]){
      
        manticore_runOnMainQueueWithoutDeadlocking(^{
            [self overlaySlideshow:[MCViewManager sharedManager].screenOverlays];
        });
      
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
  
}

# pragma mark - Callback methods


/*!
 * New Activity happened in MCViewController. UI Needs to be updated in consequence.
 *
 * 1. Load or Create the appropriate section associated with the activity
 *
 * 2. Load or Create the appropriate View associated with the activity (if relevant)
 *
 * 3. Propagation of onPause to the active Activity's childView before transitionning (-> for saving changes to previous activity)
 *
 */
- (void) updateUIWithNewActivity: (MCActivity*) activity {
    
    
    // 1.
    MCSectionViewController* sectionVC =  (MCSectionViewController*)  [self loadOrCreateViewController:[activity associatedSectionName]];
    NSAssert([sectionVC isKindOfClass:[MCSectionViewController class]], @"Your section %@ should subclass MCSectionViewController", [sectionVC description]);
    
    // 2.
    MCViewController* vc = nil;
    if ([activity associatedViewName])
    {
        vc = (MCViewController*) [self loadOrCreateViewController:[activity associatedViewName]];
        
        // Add that it shouldn't a MCSectionViewController which subclasses MCViewController
        NSAssert([vc isKindOfClass:[MCViewController class]], @"Your view %@ should subclasses MCViewController", [vc description]);
        
        /* edge case: everything we are transitioning to is the same as the previous, need to create a new view */
        // Same section same view
        if (sectionVC == _currentSectionVC && vc == _currentSectionVC.currentViewVC)
        {
            vc = (MCViewController*) [self forceLoadViewController:[activity associatedViewName]];
        }
    }
    else
    {
        // If transitionning to same Section, we reload it anyway because the new Activity only has an associated Section
        if (sectionVC == _currentSectionVC)
        {
            sectionVC = (MCSectionViewController*) [self forceLoadViewController:[activity associatedSectionName]];
        }
    }
    
    // 3.
    if (_currentSectionVC)
    {
        // reset debug flags
        _currentSectionVC.debugTag = NO;
        if (_currentSectionVC.currentViewVC)
            _currentSectionVC.currentViewVC.debugTag = NO;
        
        [_currentSectionVC onPause:_activeActivity];
        
#ifdef DEBUG
        if (!_currentSectionVC.debugTag)
            NSLog(@"Subclass %@ of MCSectionViewController did not have its [super onPause:activity] called", _currentSectionVC);
        if (_currentSectionVC.currentViewVC && !_currentSectionVC.currentViewVC.debugTag)
            NSLog(@"Subclass %@ of MCViewController did not have its [super onPause:activity] called", _currentSectionVC.currentViewVC);
#endif
    }
    
    // 3. switch the views
    [self loadNewSection:sectionVC andView:vc withActivity:activity];
    
    // reset debug flags
    _currentSectionVC.debugTag = NO;
    if (_currentSectionVC.currentViewVC)
        _currentSectionVC.currentViewVC.debugTag = NO;
    
    // 4.resume on the section will also resume the view
    _activeActivity = activity;
    [sectionVC onResume:activity];
    
#ifdef DEBUG
    if (!_currentSectionVC.debugTag)
        NSLog(@"Subclass %@ of MCSectionViewController did not have its [super onResume:activity] called", _currentSectionVC);
    if (_currentSectionVC.currentViewVC && !_currentSectionVC.currentViewVC.debugTag)
        NSLog(@"Subclass %@ of MCViewController did not have its [super onResume:activity] called", _currentSectionVC.currentViewVC);
#endif
}

-(void)overlaySlideshow:(NSArray*)overlays
{
    _screenOverlaySlideshow = overlays;
    
    if (!overlays || overlays.count == 0)
    {
        if (_screenOverlayButton)
        {
            // fade out the overlay in 200 ms
            _screenOverlayButton.alpha = 1.0;
            [UIView animateWithDuration:MANTICORE_OVERLAY_ANIMATION_DURATION animations:^{
                _screenOverlayButton.alpha = 0.0;
            } completion:^(BOOL finished) {
                [_screenOverlayButton resignFirstResponder];
                [_screenOverlayButton removeFromSuperview];
                _screenOverlayButton = nil;
            }];
        }
        return;
    }
    
    // load the overlay
    if (!_screenOverlayButton)
    {
        // set up the geometry of the new screen overlay
        CGRect rect = [self.view bounds];
        _screenOverlayButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _screenOverlayButton.frame = rect;
        _screenOverlayButton.contentMode = UIViewContentModeScaleToFill;
    }
    
    // this code will load 2 images on iPhone 5, one for the small screen and another image for the large screen
    
    // automatically remove the .png/.PNG extension
    NSString* overlayName = [overlays objectAtIndex:0];
    if ([[overlayName pathExtension] compare:@"png" options:NSCaseInsensitiveSearch] == NSOrderedSame)
    {
        overlayName = [overlayName stringByDeletingPathExtension];
    }
    // load the image
    UIImage* imgOverlay = [UIImage imageNamed:overlayName];
    
    // check screen dimensions
    CGRect appFrame = [[UIScreen mainScreen] bounds];
    if (appFrame.size.height >= MANTICORE_IOS5_SCREEN_SIZE) // add in the _5 to the filename, shouldn't append .png
    {
        // test for an iPhone 5 overlay. If available, use that overlay instead.
        overlayName = [NSString stringWithFormat:@"%@%@", overlayName, MANTICORE_IOS5_OVERLAY_SUFFIX];
        if ([UIImage imageNamed:overlayName])
        {
            imgOverlay = [UIImage imageNamed:overlayName];
        }
    }
    
    // show the new overlay
    if (imgOverlay)
    {
        [_screenOverlayButton setImage:imgOverlay forState:UIControlStateNormal];
        _screenOverlayButton.adjustsImageWhenHighlighted = NO;
        
        [_screenOverlayButton addTarget:self action:@selector(overlayButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        if (![self.view.subviews containsObject:_screenOverlayButton])
        {
            _screenOverlayButton.alpha = 0.0;
            [self.view addSubview:_screenOverlayButton ];
            [UIView animateWithDuration:MANTICORE_OVERLAY_ANIMATION_DURATION animations:^{
                _screenOverlayButton.alpha = 1.0;
            }];
        }
        [self.view bringSubviewToFront:_screenOverlayButton];
        [_screenOverlayButton becomeFirstResponder];
    }else{
#ifdef DEBUG
        NSAssert(false, @"Screen overlay not found: %@", [MCViewManager sharedManager].screenOverlay);
#endif
    }
    
}




#pragma mark - View-Controllers related


-(MCViewController*) loadOrCreateViewController:(NSString*)sectionOrViewName
{
    // create global view cache if it doesn't already exist
    if (!_dictCacheView)
    {
        _dictCacheView = [NSMutableDictionary dictionaryWithCapacity:10];
    }
    
    // test for existence
    MCViewController* vc = [_dictCacheView objectForKey:sectionOrViewName];
    if (vc == nil)
    {
        // create the view controller
        vc = (MCViewController*) [[MCViewManager sharedManager] createViewController:sectionOrViewName];
        NSAssert(vc != nil, @"VC should exist");
        
        [vc onCreate];
        [_dictCacheView setObject:vc forKey:sectionOrViewName];
    }
    
    return vc;
    
}

-(MCViewController*) forceLoadViewController:(NSString*)sectionOrViewName
{
    // create global view cache if it doesn't already exist
    if (!_dictCacheView){
        _dictCacheView = [NSMutableDictionary dictionaryWithCapacity:10];
    }
    
    // create the view controller
    MCViewController* vc = (MCViewController*) [[MCViewManager sharedManager] createViewController:sectionOrViewName];
    NSAssert(vc != nil, @"VC should exist");
    [vc onCreate];
    
    //
    [_dictCacheView setObject:vc forKey:sectionOrViewName];
    return vc;
}


// ----------------------------------------------------------------------------------------
// This method deals with switching the view during a transition
// Section may be the same, or may not.
// View may be the same, or may not
//
//
-(void)loadNewSection:(MCSectionViewController*)sectionVC andView:(MCViewController*)viewVC withActivity:(MCActivity*)activity
{
    
    // We get the wanted transition
    int transitionStyle = [activity transitionAnimationStyle];
    
    
    // 1. If the section we are going to show is different from the current one :
    //
    //      1.1. Add new Section as Child-ViewController to self
    //      1.2. Set the new Section's properties
    //      1.3. For pop animations, the new section's view has to come from behind the old view.
    //      1.4. Get a pointer to the future oldSection and resign it as first responder
    //      1.5. We apply our custom transition (or not) : in accordance with "transitionStyle".
    //      1.5.1. After completion, oldSectionVC has to be different than currentSectionVC but we make sure it is.
    //      1.5.2. Custom transition was applied, we can now remove the old Section and it's view
    //      1.6. Custom transition was not applied. If the old/new view are different then apply standard UITransition.
    //      1.6.1. Again we make sure old and new sections were different before transition so they should still be after.
    //      1.7. Reset the animation style to none. If a transition already applied on the section, no need to apply it again on VC.
    //
    //
    
    // 1.
    if (_currentSectionVC != sectionVC ){
        // 1.1
        [self addChildViewController:sectionVC];
        
        // 1.2
        CGRect rect;
        rect.origin = CGPointMake(0, 0);
        rect.size = self.view.frame.size;
        [sectionVC.view setFrame:rect];
        [sectionVC.view setHidden: false];
        
        // 1.3
        if (transitionStyle == ANIMATION_POP || transitionStyle == ANIMATION_POP_LEFT)
        {
            [self.view insertSubview:sectionVC.view belowSubview:_currentSectionVC.view];
        } else {
            [self.view addSubview:sectionVC.view];
        }
        
        // 1.4
        MCSectionViewController* oldSectionVC = _currentSectionVC;
        [oldSectionVC.currentViewVC resignFirstResponder];
        [oldSectionVC resignFirstResponder];
        
        // 1.5 : Returns True if our custom animation was applied.
        BOOL transitionApplied = [MCMainViewController applyTransitionFromView:oldSectionVC.view toView:sectionVC.view transition:transitionStyle completion:^{
            
            // 1.5.1
            if (oldSectionVC != _currentSectionVC)
            {
                // 1.5.2
                [oldSectionVC.view removeFromSuperview];
                [oldSectionVC removeFromParentViewController];
            }
        }];
        
        // 1.6
        if (!transitionApplied && oldSectionVC.view != sectionVC.view)
        {
            transitionApplied = true;
            [UIView transitionFromView:oldSectionVC.view toView:sectionVC.view duration:0.25 options:(transitionStyle | UIViewAnimationOptionShowHideTransitionViews) completion:^(BOOL finished) {
                
                // 1.6.1.
                if (oldSectionVC != _currentSectionVC)
                {
                    [oldSectionVC.view removeFromSuperview];
                    [oldSectionVC removeFromParentViewController];
                }
            }];
        }
        
        // 1.7
        transitionStyle = UIViewAnimationOptionTransitionNone;
    }
    
    
    
    
    // 2. We only want to load the "new" view if it is new -> if it was not the section's currentView the last time the section was shown.
    //      In any other cases, we need to load the view and place it as the section's currentView.
    //
    //      2.1. It is different. We can resign it as first responder to prepare for new view
    //      2.2. viewVC not nil, we can process it
    //      2.2.1. Add the new VC (viewVC) as childVC of it's Section
    //      2.2.2. Set the new VC's properties
    //      2.2.3. For pop animations, the new view has to come from behind the old view.
    //      2.2.4. See "1.5"
    //      2.2.5. See "1.6"
    //      2.3. viewVC is nil, we transition to a section without view
    //
  
    // We get a pointer the the section's old "currentView".
    MCViewController* sectionVC_oldCurrentViewVC = sectionVC.currentViewVC;
  
    // 2.
    if (sectionVC_oldCurrentViewVC != viewVC)
    {
        // 2.1
        [sectionVC_oldCurrentViewVC resignFirstResponder];
    
        // 2.2
        if (viewVC)
        {
            // 2.2.1
            [sectionVC addChildViewController:viewVC];
      
            // 2.2.2
            CGRect rect;
            rect.origin = CGPointMake(0, 0);
            rect.size = sectionVC.innerView.bounds.size;
            [viewVC.view setHidden: NO];
            [viewVC.view setFrame:rect];
            
            // 2.2.3
            if (transitionStyle == ANIMATION_POP || transitionStyle == ANIMATION_POP_LEFT)
            {
                [sectionVC.innerView insertSubview:viewVC.view belowSubview:sectionVC_oldCurrentViewVC.view];
            } else {
                [sectionVC.innerView addSubview:viewVC.view];
            }
      
      
            // 2.2.4
            BOOL opResult = [MCMainViewController applyTransitionFromView:sectionVC_oldCurrentViewVC.view toView:viewVC.view transition:transitionStyle completion:^{
        
                if (sectionVC.currentViewVC != sectionVC_oldCurrentViewVC)
                {
                    [sectionVC_oldCurrentViewVC.view removeFromSuperview];
                    [sectionVC_oldCurrentViewVC removeFromParentViewController];
                }
            }];
      
            //2.2.5
            if (sectionVC_oldCurrentViewVC.view != viewVC.view && !opResult){
        
                [UIView transitionFromView:sectionVC_oldCurrentViewVC.view toView:viewVC.view duration:0.50 options:(transitionStyle |UIViewAnimationOptionShowHideTransitionViews) completion:^(BOOL finished) {
                    if (sectionVC.currentViewVC != sectionVC_oldCurrentViewVC)
                    {
                        [sectionVC_oldCurrentViewVC.view removeFromSuperview];
                        [sectionVC_oldCurrentViewVC removeFromParentViewController];
                    }
                }];
            }
        }
        // 2.3
        else
        {
            [sectionVC_oldCurrentViewVC.view removeFromSuperview];
            [sectionVC_oldCurrentViewVC removeFromParentViewController];
        }
    
        
        // Why ???
        NSAssert(sectionVC.innerView.subviews.count < 5, @"clearing the view stack");
    }
  
    // We applied the transitions so we can now set the new (or not) section and new (or not) view.
    _currentSectionVC = sectionVC;
    _currentSectionVC.currentViewVC = viewVC;
}




- (void)overlayButtonPressed:(id)sender
{
    NSMutableArray* newArray = [NSMutableArray arrayWithArray:_screenOverlaySlideshow];
    if (newArray.count > 0)
    {
        [newArray removeObjectAtIndex:0];
    }
    _screenOverlaySlideshow = newArray;
    [self overlaySlideshow:newArray];
}




#pragma mark - 
#pragma mark - Utils

// -------------------------------------------------------------------------------------------
// this method offers custom animations that are not provided by UIView, mainly the
// slide left and right animations (no idea why Apple separated these animations)
//
// The boolean returns true if our animations were asked (and therefore applied).
//
+(BOOL)applyTransitionFromView:(UIView*)oldView toView:(UIView*)newView transition:(int)transitionValue completion:(void (^)(void))completion  {
    
    // Get all the necessary positions to apply the custom transitions
    
    CGPoint finalPosition = oldView.center;
    CGPoint leftPosition = CGPointMake(-oldView.frame.size.width + finalPosition.x, finalPosition.y);
    CGPoint rightPosition = CGPointMake(finalPosition.x + oldView.frame.size.width, finalPosition.y);
    
    CGPoint closerLeftPosition = CGPointMake(finalPosition.x - 40, finalPosition.y);
    CGPoint closerRightPosition = CGPointMake(finalPosition.x + 40, finalPosition.y);
    
    
    CGPoint topPosition = CGPointMake(finalPosition.x, finalPosition.y + oldView.frame.size.height);
    CGPoint bottomPosition = CGPointMake(finalPosition.x, -oldView.frame.size.height + finalPosition.y);
    
    
    // Returns true if "transitionValue" applies to our own transitions.
    // Return false otherwise.
    
    switch (transitionValue) {
            
        case ANIMATION_PUSH:
        {
            newView.center = rightPosition;
            oldView.center = finalPosition;
            
            [UIView animateWithDuration:0.5 animations:^{
                newView.center = finalPosition;
                oldView.center = closerLeftPosition;
                
            } completion:^(BOOL finished) {
                completion();
                oldView.center = finalPosition;
            }];
            return YES;
            break;
        }
            
            
        case ANIMATION_PUSH_LEFT:
        {
            newView.center = leftPosition;
            oldView.center = finalPosition;
            
            [UIView animateWithDuration:0.5 animations:^{
                newView.center = finalPosition;
                oldView.center = closerRightPosition;
                
            } completion:^(BOOL finished) {
                completion();
                oldView.center = finalPosition;
            }];
            return YES;
            break;
        }
            
            
        case ANIMATION_POP:
        {
            newView.center = closerLeftPosition;
            oldView.center = finalPosition;
            
            [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationOptionShowHideTransitionViews animations:^{
                newView.center = finalPosition;
                oldView.center = rightPosition;
            } completion:^(BOOL finished) {
                completion();
                oldView.center = finalPosition;
            }];
            return YES;
            break;
        }
            
            
        case ANIMATION_POP_LEFT:
        {
            newView.center = closerRightPosition;
            oldView.center = finalPosition;
            
            [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationOptionShowHideTransitionViews animations:^{
                newView.center = finalPosition;
                oldView.center = leftPosition;
            } completion:^(BOOL finished) {
                completion();
                oldView.center = finalPosition;
            }];
            return YES;
            break;
        }
            
            
        case ANIMATION_SLIDE_FROM_BOTTOM:
        {
            newView.center = topPosition;
            
            [UIView animateWithDuration:0.5 animations:^{
                newView.center = finalPosition;
            } completion:^(BOOL finished) {
                completion();
                oldView.center = finalPosition;
            }];
            return YES;
            break;
        }
            
            
        case ANIMATION_SLIDE_FROM_TOP:
        {
            newView.center = bottomPosition;
            
            [UIView animateWithDuration:0.5 animations:^{
                newView.center = finalPosition;
            } completion:^(BOOL finished) {
                completion();
                oldView.center = finalPosition;
            }];
            return YES;
            break;
        }
            
            
        default:
        {
            return NO;
            break;
        }
    }
}


@end
