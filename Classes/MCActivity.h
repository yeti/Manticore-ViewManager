//
//  MCActivity.h
//  Pods
//
//  Created by Philippe Bertin on 8/7/14.
//
//

#import <Foundation/Foundation.h>

@interface MCActivity : NSObject


/*!
 * Getter for the Activity's related section name
 */
@property (strong, nonatomic, readonly) NSString* associatedSectionName;


/*!
 * Getter for the Activity's related view name.
 * @discussion Returns nil if no View is associated with the Activity.
 */
@property (strong, nonatomic, readonly) NSString* associatedViewName;


/*!
 * Getter fot the activity Infos : the data the user wants to associate with the activity.
 *
 * As many objects as needed may be added to this dictionary : it will then be available when the Activity's viewController is created, resumed and paused.
 *
 * Be aware that this dictionary will take space in memory until this Activity is flushed from the stack.
 */
@property (strong, nonatomic, readonly) NSMutableDictionary* activityInfos;


/*!
 * Getter and setter for this Activity's animation style.
 *
 * The animation style will be used to transition between the currentActivity and this Activity.
 *
 * Prefered animations are ANIMATION_NOTHING, ANIMATION_PUSH, ANIMATION_POP, UIViewAnimationOptionTransitionCrossDissolve. Other UI transitions work.
 *
 * If no animationStyle is set, ANIMATION_NOTHING is the default.
 */
@property (nonatomic, readwrite) UIViewAnimationOptions transitionAnimationStyle;


/*!
 * Creates an activity only associated with a section
 *
 */
-(id)initWithAssociatedSectionNamed:(NSString *)sectionName;


/*!
 * Creates an activity associated with a View in a Section.
 *
 */
-(id)initWithAssociatedViewNamed:(NSString *)viewName
                  inSectionNamed:(NSString *)sectionName;


@end
