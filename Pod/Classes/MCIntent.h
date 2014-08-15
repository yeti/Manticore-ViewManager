/*
  MCActivity.h
  Manticore View Manager

  Created by Richard Fung on 9/19/12.
  Reworked, refactored and commented by Philippe Bertin on August 1, 2014
  Copyright (c) 2014 Yeti LLC. All rights reserved.

 
 ///////////////////////////////////////////////////////////////

 see the architecture design from Android:
 http://developer.android.com/reference/android/app/Activity.html

 ViewControllers are "activities" that receive bundles
 
 ///////////////////////////////////////////////////////////////
 
 
 How to use:

 1.  MCActivity* activity = [MCActivity activityWithSectionName:SECTION_?? viewName:VIEW_??]
     Create the Activity object

 2. [[activity getSavedInstance] setObject:?? forKey:@"viewSpecificKey"]
     Assign any/all view-specific instructions. Read header files for definition.

 3. [[MCViewManager sharedManager] processActivity:activity];
     Load the section.
*/

#import <Foundation/Foundation.h>
#import "MCConstants.h"
#import "MCStackRequestDescriptor.h"
#import "MCActivity.h"



@interface MCIntent : NSObject


/*!
 * The data the user wants to associate with the activity. Note that if the Activity already exists, it will be added on top of the activityInfos.
 *
 * As many objects may be added to this dictionary : it will then be available when the Activity's viewController is created, resumed and paused.
 *
 * Be aware that this dictionary will take space in memory until its Activity is flushed from the stack.
 */
@property (strong, nonatomic, readonly) NSMutableDictionary* userInfos;

/*!
 * Activity's transition animation style. The animation style will be used to transition from the current Activity's View to the Activity that will be related to this intent.
 *
 * Prefered animations are ANIMATION_NOTHING, ANIMATION_PUSH, ANIMATION_POP, UIViewAnimationOptionTransitionCrossDissolve. Other UI transitions work.
 *
 * If no transitionAnimationStyle is set, ANIMATION_NOTHING is the default.
 */
@property (readwrite) UIViewAnimationOptions transitionAnimationStyle;




#pragma mark - Understanding Activities and How to Read the schemas

/* 
 *            **--------------**
 *            **  Activities  **
 *            **--------------**
 *
 *  Activities are always related to a Section and should always be related to a View.
 *  An Activity contains :
 *          - associatedSectionName   : the intent's associated Section.
 *          - associatedViewName      : the intent's associated View 
 *          - animationStyle: the animation style when switching from the current View to the Intent's View (-> when the intent is processed)
 *          - activityInfos  : the data associated with the Activity. When creating an Intent, add some entries in the "userInfos" dictionary. This dictionary will then added to the Activity's dictionary when created/loaded from stack. The View can then access this dictionary when Manticore calls the functions "onCreate", "onResume" and "onPause". Implement these methods in your View to have them automatically called.
 
 *  You don't manage activities yourself. Instead, you make intents and process then with MCViewManager.
 *  Before they are processed, intents can have two forms : 
 *      1. "Static" : when creating new intents (with the methods : "intentWith...")
 *      2. "Dynamic" (also named "navigation intent") : the intent contains a request for an already existing Intent in the history stack. It will contain all the elements in the above list AFTER it is processed.
 *
 *
 *            **---------------------------**
 *            **  HOW TO READ THE SCHEMAS  **
 *            **---------------------------**
 *
 *               +-- The Section the Activity is related to
 *               |       +-- A column represent an Activity in the stack (with its related Section and View)
 *               |       |
 *               V       V
 * +--------+---- ----++---+---+---+---+---+---+---+---+---+---+-+-+
 * |        |SectionVC|| 1 | 1 | 1 | 2 | 2 | 1 | 1 | 3 | 3 | 3 | 3 |\
 * | Stack  +---------||---+---+---+---+---+---+---+---+---+---+---| >- Latest intent
 * |        | ViewVC  || 11| 12| 13| 21| 22| 21| 12| 31| 32| 34| 33|/
 * +--------+---- ----++- -+---+---+---+---+---+---+---+---+---+- -+
 *               ^        \_ From oldest intent to the lastest _/
 *               |
 *               +-- The View the Intent is related to
 *
 *
 *  "View (name)"       = (name of the) view-controller sub-classing MCViewController
 *                      = ViewVC in the schema : View11VC, View12VC, View21VC, etc.
 *
 *  "Section (name)"    = (name of the) view-controller sub-classing MCSectionViewController.
 *                      = SectionVC in schema  : Section1VC, Section2VC and Section3VC
 *
 *
 */



#pragma mark - New Activity creation methods


/*            **-------------------------------------------------------------**
 *            **  Schema for "intentNewActivityWithAssociatedSectionNamed:"  **
 *            **-------------------------------------------------------------**
 *
 *
 * Method used in example : "intentNewActivityWithAssociatedSectionNamed:Section3VC"
 *
 * +--------+---------++---+---+---+---+---+---+---+---+---+---+-+-+     +---+
 * |        |SectionVC|| 1 | 1 | 1 | 2 | 2 | 1 | 1 | 3 | 3 | 3 | 3 |     | 3 |
 * | Stack  +---------||---+---+---+---+---+---+---+---+---+---+---+ --> +---+
 * |        | ViewVC  || 11| 12| 13| 21| 22| 21| 12| 31| 32| 34| 33|     |   |
 * +--------+---------++---+---+---+---+---+---+---+---+---+---+---+     +---+
 *
 */

/*!
 * @function intentNewActivityWithAssociatedSectionNamed
 * @discussion Sections without Views should be avoided.
 * @discussion Creates and return a new intent.
 *
 * @param sectionName       The Section the Activity will be related to
 */
+(MCIntent *) intentNewActivityWithAssociatedSectionNamed: (NSString*) sectionName;

/*!
 * @function intentNewActivityWithAssociatedSectionNamed andActivityInfos
 * @discussion Only used by the undo operation.
 * @discussion Creates and return a new Activity. This Activity will not be related to any View, only a Section. Behavior has not been tested.
 * @discussion Instead, we recommand creating a dummy MCSectionViewController sub-class and then create Activities related to this Section for your Views that can not be grouped in Sections.
 * @param sectionName       The Section the Activity will be related to
 * @param andSavedInstance  The Activity's savedInstance dictionary
 */
+(MCIntent *) intentNewActivityWithAssociatedSectionNamed: (NSString*) sectionName
                                         andActivityInfos: (NSMutableDictionary*) activityInfos;

/*!
 * @function intentNewActivityWithAssociatedSectionNamed andAnimation
 * @discussion Creates and return a new Activity. This Activity will not be related to any View, only a Section. Behavior has not been tested.
 * @discussion Instead, we recommand creating a dummy MCSectionViewController sub-class and then create Activities related to this Section for your Views that can not be grouped in Sections.
 *
 * @param sectionName   The Section the Activity will be related to
 * @param animation     The animation to this Activity's Section when processed.
 * @discussion Prefered animations are ANIMATION_NOTHING, ANIMATION_PUSH, ANIMATION_POP, UIViewAnimationOptionTransitionCrossDissolve. Other UI transitions work.
 */
+(MCIntent *) intentNewActivityWithAssociatedSectionNamed: (NSString*) name
                                             andAnimation: (UIViewAnimationOptions) animation;




/*            **--------------------------------------------------------------------------**
 *            **  Schema for "intentNewActivityWithAssociatedViewNamed: inSectionNamed:"  **
 *            **--------------------------------------------------------------------------**
 *
 *
 * Input in example : "newActivityWithAssociatedViewNamed:Section3VC andRelatedViewName:View35VC"
 *
 * +--------+---------++---+---+---+---+---+---+---+---+---+---+-+-+     +---+
 * |        |SectionVC|| 1 | 1 | 1 | 2 | 2 | 1 | 1 | 3 | 3 | 3 | 3 |     | 3 |
 * | Stack  |---------||---+---+---+---+---+---+---+---+---+---+---+ --> +---+
 * |        | ViewVC  || 11| 12| 13| 21| 22| 21| 12| 31| 32| 34| 33|     | 35|
 * +--------+---------++---+---+---+---+---+---+---+---+---+---+---+     +---+
 *
 */

/*!
 * @function intentNewActivityWithAssociatedViewNamed inSectionNamed
 * @discussion Creates and return an intent for a new Activity associated to a View in a Section.
 *
 * @param sectionName   The Section the Activity will be related with
 * @param viewName      The View the Activity will be related to
 */
+(MCIntent *) intentNewActivityWithAssociatedViewNamed: (NSString*) viewName
                                        inSectionNamed: (NSString*) sectionName;

/*!
 * @function intentNewActivityWithAssociatedViewNamed: inSectionNamed: andAnimation:
 * @discussion Creates and return an intent for a new Activity associated to a View in a Section.
 *
 * @param sectionName   The Section the Activity will be related with
 * @param viewName      The View the Activity will be related to
 * @param animation     The animation to this Activity's View when processed. 
 * @discussion Prefered animations are ANIMATION_NOTHING, ANIMATION_PUSH, ANIMATION_POP, UIViewAnimationOptionTransitionCrossDissolve. Other UI transitions work.
 */
+(MCIntent *) intentNewActivityWithAssociatedViewNamed: (NSString*)viewName
                                        inSectionNamed: (NSString*)sectionName
                                          andAnimation: (UIViewAnimationOptions)animation;




#pragma mark - Navigation Intents

#pragma mark - Push Methods


/*            **---------------------------------------------**
 *            **  Schema for "intentPushActivityFromHistory" **
 *            **---------------------------------------------**
 *
 * Inputs in example :
 *    - intentPushActivityFromHistoryByPosition: 6
 * or - intentPushActivityFromHistoryByName: @"View22VC"
 *
 *                                       +---------------------------+
 *                                       |                           |
 * +--------+---------++---+---+---+---+-+-+---+---+---+---+---+---+ |
 * |        |SectionVC|| 1 | 1 | 1 | 2 | 2 | 1 | 1 | 3 | 3 | 3 | 3 | |
 * | Stack  |---------||---+---+---+---+---+---+---+---+---+---+---+ |
 * | before | ViewVC  || 11| 12| 13| 21| 22| 21| 12| 31| 32| 34| 33| |
 * +--------+---------++---+---+---+---+---+---+---+---+---+---+- -+ |
 *    |                                                          |   |
 *    |                          Activity position 0 in stack ---+   |
 *    v                                                              v
 * +--------+---------++---+---+---+---X---X---+---+---+---+---+---+---+
 * |        |SectionVC|| 1 | 1 | 1 | 2 |XXX| 1 | 1 | 3 | 3 | 3 | 3 | 2 |
 * | Stack  |---------||---+---+---+---+-X-+---+---+---+---+---+---+---+
 * |        | ViewVC  || 11| 12| 13| 21|XXX| 21| 12| 31| 32| 34| 33| 22|
 * +--------+---------++---+---+---+---X---X---+---+---+---+---+---+---+
 *    |
 *    v
 * +--------+---------++---+---+---+---+---+---+---+---+---+---+---+
 * |        |SectionVC|| 1 | 1 | 1 | 2 | 1 | 1 | 3 | 3 | 3 | 3 | 2 |
 * | Stack  |---------||---+---+---+---+---+---+---+---+---+---+---+
 * | after  | ViewVC  || 11| 12| 13| 21| 21| 12| 31| 32| 34| 33| 22|
 * +--------+---------++---+---+---+---+---+---+---+---+---+---+---+
 *                                                               |
 *                               Activity position 0 in stack ---+
 */

/*!
 * @function intentPushActivityFromHistory
 * Intent to Push a specific Activity from the history stack to the top of the stack.
 * @discussion Push means that when found, the Activity will be removed from its position in the stack and placed on top of the stack.
 * @param ptrActivity Pointer to the Activity to push on top of the stack.
 * @return New pointer to the Activity, make sur to replace old one with this one.
 */
+(MCIntent *) intentPushActivityFromHistory: (MCActivity *) ptrToActivity;

/*!
 * @function intentPushActivityFromHistoryByPosition
 * Intent to Push an Activity to the top of the stack, given its position in the stack.
 * @discussion Push means that when found, the Activity will be removed from its position in the stack and placed on top of the stack.
 * @param positionInStack Activity's position in the stack. Position 1 = last Activity in the history stack. Has to be > 0.
 */
+(MCIntent *) intentPushActivityFromHistoryByPosition: (int) positionInStack;

/*!
 * @function intentPushActivityFromHistoryByName
 * Intent to Push an Activity to the top of the stack, given it's associated View's name.
 * @discussion Push means that when found, the Activity will be removed from its position in the stack and placed on top of the stack.
 * @discussion /!\ WARNING /!\ Because multiple Activities might have the same name, this method will find the first Activity matching the given name in the history stack and push it on top of the stack.
 * @param mcViewControllerName Name of the MCViewController (View) associated with the Activity to find.
 */
+(MCIntent *) intentPushActivityFromHistoryByName: (NSString *) mcViewControllerName;




#pragma mark - Pop methods

#pragma mark Pop to an Activity in History

/*            **---------------------------------------------**
 *            **  Schema for "intentPopToActivityInHistory"  **
 *            **---------------------------------------------**
 *
 * Method used in example :
 *       - intentPopToActivityInHistoryByPosition: 6
 *   or  - intentPopToActivityInHistoryByName: @"View22VC"
 *
 *                                       |
 *                                       v
 * +--------+---------++---+---+---+---+---+---+---+---+---+---+---+
 * |        |SectionVC|| 1 | 1 | 1 | 2 | 2 | 1 | 1 | 3 | 3 | 3 | 3 |
 * | Stack  |---------||---+---+---+---+---+---+---+---+---+---+---|
 * | before | ViewVC  || 11| 12| 13| 21| 22| 21| 12| 31| 32| 34| 33|
 * +--------+---------++---+---+---+---+---+---+---+---+---+---+- -+
 *                                                               |
 *                               Activity position 0 in stack ---+
 *
 * +--------+---------++---+---+---+---+---+
 * |        |SectionVC|| 1 | 1 | 1 | 2 | 2 |
 * | Stack  |---------||---+---+---+---+---|
 * | after  | ViewVC  || 11| 12| 13| 21| 22|
 * +--------+---------++---+---+---+---+---+
 *                                       |
 *       Activity position 0 in stack ---+
 *
 *
 */

/*!
 * @function intentPopToActivityInHistory
 * Intent to Pop to a specific Activity in the history stack.
 * @discussion Pop means removing one by one each Activity in the history stack until finding the one it is looking for.
 * @param ptrActivity Pointer to the Activity to pop to.
 * @return New pointer to the Activity, make sur to replace old one with this one.
 */
+(MCIntent *) intentPopToActivityInHistory: (MCActivity *) ptrToActivity;

/*!
 * @function intentPopToActivityInHistoryByPosition
 * Intent to Pop to an Activity given its position in the stack.
 * @discussion Pop means removing one by one each Activity in the history stack until finding the one it is looking for.
 *
 * @param positionInStack Activity's position in the stack. Position 1 = last Activity in the history stack. Has to be > 0.
 */
+(MCIntent *) intentPopToActivityInHistoryByPosition: (int) positionInStack;

/*!
 * @function intentPopToActivityInHistoryByPositionLast
 * Intent to Pop to the last Activity in the history stack.
 * @discussion Same as using popToActivityInHistoryByPosition:1
 */
+(MCIntent *) intentPopToActivityInHistoryByPositionLast;

/*!
 * @function intentPopToActivityInHistoryByName
 * Intent to Pop to an Activity, given it's associated View's name.
 * @discussion Pop means removing one by one each Activity in the history stack until finding the one it is looking for.
 * @discussion /!\ WARNING /!\ Because multiple Activities might have the same name, this method will find the first Activity matching the given name in the history stack and pop to it.
 *
 * @param mcViewControllerName Name of the View associated with the Activity to find. Can also be a Section with no Views.
 */
+(MCIntent *) intentPopToActivityInHistoryByName: (NSString *) mcViewControllerName;




#pragma mark Pop to Sections' Root Activity


/*            **----------------------------------------**
 *            **  Schema for "intentPopToActivityRoot"  **
 *            **----------------------------------------**
 *
 *
 * +--------+---------++---+---+---+---+---+---+---+---+---+---+---+
 * |        |SectionVC|| 1 | 1 | 1 | 2 | 2 | 1 | 1 | 3 | 3 | 3 | 3 |
 * | Stack  |---------||---+---+---+---+---+---+---+---+---+---+---|
 * | before | ViewVC  || 11| 12| 13| 21| 22| 21| 12| 31| 32| 34| 33|
 * +--------+---------++---+---+---+---+---+---+---+---+---+---+- -+
 *                                                               |
 *                               Activity position 0 in stack ---+
 *
 * +--------+---------++---+
 * |        |SectionVC|| 1 |
 * | Stack  |---------||---|
 * | after  | ViewVC  || 11|
 * +--------+---------++- -+
 *                       |
 * Activity position 0 --+
 *
 *
 *
 */

/*!
 * @function intentPopToActivityRoot
 * Intent to Pop to the root Activity in the history stack.
 * @discussion Pop means removing one by one each Activity in the history stack until finding the one it is looking for (the root Activity here).
 */
+(MCIntent *) intentPopToActivityRoot;




/*            **--------------------------------------------------**
 *            **  Schema for "popToActivityRootInSectionCurrent"  **
 *            **--------------------------------------------------**
 *
 *
 * +--------+---------++---+---+---+---+---+---+---+---+---+---+---+
 * |        |SectionVC|| 1 | 1 | 1 | 2 | 2 | 1 | 1 | 3 | 3 | 3 | 3 |
 * | Stack  |---------||-------------------------------------------+
 * | before | ViewVC  || 11| 12| 13| 21| 22| 21| 12| 31| 32| 34| 33|
 * +--------+---------++---+---+---+---+---+---+---+---+---+---+- -+
 *                                                               |
 *                               Activity position 0 in stack ---+
 *
 * +--------+---------++---+---+---+---+---+---+---+---+
 * |        |SectionVC|| 1 | 1 | 1 | 2 | 2 | 1 | 1 | 3 |
 * | Stack  |---------||-------------------+------------
 * | after  | ViewVC  || 11| 12| 13| 21| 22| 21| 12| 31|
 * +--------+---------++---+---+---+---+---+---+---+---+
 *                                                   |
 *                   Activity position 0 in stack ---+
 *
 * Infos : current section is Section3VC and the root View in this section is View31VC.
 *
 */

/*!
 * @function intentPopToActivityRootInSectionCurrent
 * Intent to Pop to the root Activity of the current section in the history stack.
 * @discussion Pop means removing one by one each Activity in the history stack until finding the one it is looking for (the root Activity of the current section here).
 *
 * If current Activity is already root, this intent will not be processed (processIntent will return a nil activity).
 */
+(MCIntent *) intentPopToActivityRootInSectionCurrent;




/*            **-----------------------------------------------------**
 *            **  Schema for "intentPopToActivityRootInSectionLast"  **
 *            **-----------------------------------------------------**
 *
 *
 * +--------+---------++---+---+---+---+---+---+---+---+---+---+---+
 * |        |SectionVC|| 1 | 1 | 1 | 2 | 2 | 1 | 1 | 3 | 3 | 3 | 3 |
 * | Stack  |---------||-------------------------------------------+
 * | before | ViewVC  || 11| 12| 13| 21| 22| 21| 12| 31| 32| 34| 33|
 * +--------+---------++---+---+---+---+---+---+---+---+---+---+- -+
 *                                                               |
 *                               Activity position 0 in stack ---+
 *
 * +--------+---------++---+---+---+---+---+---+
 * |        |SectionVC|| 1 | 1 | 1 | 2 | 2 | 1 |
 * | Stack  |---------||-------------------+----
 * | after  | ViewVC  || 11| 12| 13| 21| 22| 21|
 * +--------+---------++---+---+---+---+---+- -+
 *                                           |
 *           Activity position 0 in stack ---+
 *
 *
 * Infos : last section is Section1VC and the root View in this section is View21VC.
 */

/*!
 * @function intentPopToActivityRootInSectionLast
 * Intent to Pop to the root Activity of the last section in the history stack.
 * @discussion Pop means removing one by one each Activity in the history stack until finding the one it is looking for (the root Activity of the last section here).
 */
+(MCIntent *) intentPopToActivityRootInSectionLast;




/*            **------------------------------------------------------**
 *            **  Schema for "intentPopToActivityRootInSectionNamed"  **
 *            **------------------------------------------------------**
 *
 *  Method used in example : "intentPopToActivityRootInSectionNamed:@"Section1VC"
 *
 * +--------+---------++---+---+---+---+---+---+---+---+---+---+---+
 * |        |SectionVC|| 1 | 1 | 1 | 2 | 2 | 1 | 1 | 3 | 3 | 3 | 3 |
 * | Stack  |---------||-------------------------------------------+
 * | before | ViewVC  || 11| 12| 13| 21| 22| 21| 12| 31| 32| 34| 33|
 * +--------+---------++---+---+---+---+---+---+---+---+---+---+- -+
 *                                                               |
 *                               Activity position 0 in stack ---+
 *
 * +--------+---------++---+---+---+---+---+---+
 * |        |SectionVC|| 1 | 1 | 1 | 2 | 2 | 1 |
 * | Stack  |---------||-------------------+----
 * | after  | ViewVC  || 11| 12| 13| 21| 22| 21|
 * +--------+---------++---+---+---+---+---+- -+
 *                                           |
 *           Activity position 0 in stack ---+
 *
 *
 * Infos : first occurence of Section1VC in the stack is in position 4, then root view in section is View21VC
 * Warning : As you can see, Section1 appears again later in the stack, 
 *      but because there is another Section in between (Section2), it won't go there.
 */

/*!
 * @function intentPopToActivityRootInSectionNamed
 * Intent to Pop to the root Activity of the section with the given name.
 * @discussion Pop means removing one by one each Activity in the history stack until finding the one it is looking for (the root Activity of the given section).
 * /!\ WARNING /!\ This method will find the first Activity in the stack that is related to the given Section name and then find the root in the Section. If the Section appears again previously in the stack, it will not be reached. See header comments for a visual representation of this warning.
 * @param mcSectionViewControllerName Name of the MCSectionViewController (Section) associated with the Activity to find.
 */
+(MCIntent *) intentPopToActivityRootInSectionNamed: (NSString *) mcSectionViewControllerName;




#pragma mark Pop to Sections' last Activity



/*            **-----------------------------------------------------**
 *            **  Schema for "intentPopToActivityLastInSectionLast"  **
 *            **-----------------------------------------------------**
 *
 * +--------+---------++---+---+---+---+---+---+---+---+---+---+---+
 * |        |SectionVC|| 1 | 1 | 1 | 2 | 2 | 1 | 1 | 3 | 3 | 3 | 3 |
 * | Stack  |---------||-------------------------------------------+
 * | before | ViewVC  || 11| 12| 13| 21| 22| 21| 12| 31| 32| 34| 33|
 * +--------+---------++---+---+---+---+---+---+---+---+---+---+- -+
 *                                                               |
 *                               Activity position 0 in stack ---+
 *
 * +--------+---------++---+---+---+---+---+---+
 * |        |SectionVC|| 1 | 1 | 1 | 2 | 2 | 1 |
 * | Stack  |---------||-------------------+----
 * | after  | ViewVC  || 11| 12| 13| 21| 22| 21|
 * +--------+---------++---+---+---+---+---+- -+
 *                                           |
 *           Activity position 0 in stack ---+
 *
 *
 * Infos : SectionLast is Section1VC. Inside this section, ActivityLast is the last encountered Activity : the one pointing to View12VC.
 */

/*!
 * @function intentPopToActivityLastInSectionLast
 * Intent to Pop to the root Activity of the current section in the history stack.
 * @discussion Pop means removing one by one each Activity in the history stack until finding the one it is looking for (the root Activity of the current section).
 */
+(MCIntent *) intentPopToActivityLastInSectionLast;




/*            **------------------------------------------------------**
 *            **  Schema for "intentPopToActivityLastInSectionNamed"  **
 *            **------------------------------------------------------**
 *
 * Method used in example : "intentPopToActivityLastInSectionNamed:@"Section1VC"
 *
 * +--------+---------++---+---+---+---+---+---+---+---+---+---+---+
 * |        |SectionVC|| 1 | 1 | 1 | 2 | 2 | 1 | 1 | 3 | 3 | 3 | 3 |
 * | Stack  |---------||-------------------------------------------+
 * | before | ViewVC  || 11| 12| 13| 21| 22| 21| 12| 31| 32| 34| 33|
 * +--------+---------++---+---+---+---+---+---+---+---+---+---+- -+
 *                                                               |
 *                               Activity position 0 in stack ---+
 *
 * +--------+---------++---+---+---+---+---+---+---+
 * |        |SectionVC|| 1 | 1 | 1 | 2 | 2 | 1 | 1 |
 * | Stack  |---------||-------------------+---+---|
 * | after  | ViewVC  || 11| 12| 13| 21| 22| 21| 12|
 * +--------+---------++---+---+---+---+---+---+- -+
 *                                               |
 *               Activity position 0 in stack ---+
 *
 *
 * Infos : first occurence of Section named "Section1VC" in the stack is in position 4, which is also the position of the ActivityLast (always).
 * Warning : As you can see, Section1 appears again later in the stack,
 *      but because there is another Section in between (Section2), it won't go there.
 */

/*!
 * @function intentPopToActivityLastInSectionNamed
 * Intent to Pop to the last Activity (first encountered Activity when rewinding the stack) of the section with the given name.
 * @discussion Pop means removing one by one each Activity in the history stack until finding the one it is looking for.
 * /!\ WARNING /!\ This method will find the first Activity in the stack that is related to the given Section name. If the Section appears again previously in the stack, it will not be reached. See header comments for a visual representation of this warning.
 * @param mcSectionViewControllerName Name of the MCSectionViewController (Section) associated with the Activity to find.
 */
+(MCIntent *) intentPopToActivityLastInSectionNamed: (NSString *) mcSectionViewControllerName;



#pragma mark - internal accessors

@property (strong, nonatomic, readonly) NSString *sectionName;
@property (strong, nonatomic, readonly) NSString *viewName;
@property (strong, nonatomic, readonly) MCStackRequestDescriptor *stackRequestDescriptor;

@end
