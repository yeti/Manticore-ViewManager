//
//  MCViewManager.h
//  Manticore iOS-ViewManager
//
//  Created by Philippe Bertin on August 1, 2014
//  Copyright (c) 2014 Yeti LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MCConstants.h"
#import "MCActivity.h"
#import "MCIntent.h"



/*
//  MCViewManager is responsible for managing and processing the
//      application's view-controllers. Whenever possible, you 
//      should use Activities to handle your View-Controllers. 
//      If you can not for some reason,
//      a method is provided to you for easy VC creation.
//
//  You should use this class to manage your view-controllers :
//
//      - Process an Activity pointing to your desired VC
//      - Clear the VCs cache
//      - Clear your view-controller's history stack
//      - Show error-messages
//      - Create view-controllers that do not need to be managed by
//          manticore. Example
//
//
*/
@interface MCViewManager : NSObject


/*!
 * Name of the screen overlay : naming convention of UIImage. Do not include extension.
 * May be suffixed by _5 for iPhone 5 screen size overlay.
 *
 */
@property(nonatomic, strong) NSString          *screenOverlay;


/*!
 * Array of strings for multiple overlays. Naming convention of UIImage. Do not include extension.
 * May be suffixed by _5 for iPhone 5 screen size overlay.
 *
 */
@property(nonatomic, strong) NSArray           *screenOverlays;


/*!
 * Valid settings are STACK_SIZE_DISABLED, STACK_SIZE_UNLIMITED, and > 0.
 * Stack size includes the current view controller.
 *
 */
@property(nonatomic) int stackSize;


/*!
 * Getter for the history stack count of elements.
 * @discussion Count=1 means only the current Activity is in the stack and therefore navigationIntents should't be processed.
 *
 */
@property(nonatomic, readonly) int historyStackCount;



/*!
 * @return The Singleton instance
 *
 */
+(MCViewManager*)sharedManager;


/*!
 * Low-level function for creating View-Controllers that won't be managed by Activities.
 * Does not provide caching and Activities events (onCreate, onResume...)
 *
 * @param sectionOrViewName Name of the UIViewController sub-class owning the nib file. Nib file must have the same name as the class.
 * @return The created View-Controller
 *
 */
-(UIViewController*)createViewController:(NSString*)sectionOrViewName;



/*!
 *
 * To become an activity, an Intent has to be processed through this method. Two types of intents :
 *
 * 1. Intent to create an activity : the newly created activity will be returned then processed to appear on screen.
 *
 * 2. Intent to pop or push an activity from the History Stack (also called "navigation intent") : MCViewManager will try to find the activity described in the intent and pop/push it on top of the stack and returns it to you.
 *
 * Because of the Manticore MVC pattern, will be returned the pointer to the "about to become active" activity BEFORE it actually becomes active. This should not matter because Activities shall never be manipulated directly (-> no risk to manipulate it before it shows up on screen). You should only keep the returned pointer if you intend to use it for stack navigation (you will give this pointer as a parameter when creating a navigation intent).
 *
 *
 * @param intent The intent that will be processed to become an Activity
 * @return The Activity corresponding to your processed intent. The MCIntent provided methods for navigating between activities should most of time be enough for your needs. However you can still keep a pointer to the activity if needed.
 *
 */
- (MCActivity *)processIntent:(MCIntent *)intent;


/*!
 * Called to clear all activities from the history stack.
 *
 * This method does not clear the View cache. See "clearViewCache".
 */
- (void)clearHistoryStack;


/*!
 * Clear the cached UIViewControllers created by MCMainViewController
 *
 * This method does not clear the history stack of activities. See "clearHistoryStack".
 */
- (void)clearViewCache;



/*!
 * Using this function will shows an error message above the main window given the title and description.
 *
 * It will not affect the history stack.
 */
- (void)setErrorTitle:(NSString*) title andDescription:(NSString*) description;


@end
