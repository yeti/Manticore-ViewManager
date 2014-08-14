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
 *  Activities store information about are always related to a Section and should always be related to a View.
 *  An Activity contains :
 *          - sectionName   : the intent's related Section.
 *          - viewName      : the intent's related View -> the MCViewController that should be loaded when intent is processed
 *          - animationStyle: the animation style when switching from the current View to the Intent's View (-> when the intent is processed)
 *          - a dictionary  : the data you want to associate with the intent. In the View associated with the intent, you can use this dictionary to show the right data. Manticore call the functions "onCreate", "onResume" and "onPause" when displaying Views and provide the Intent so that you can retrieve the data from this Dictionary.
 
 *  However, this is true AFTER intents are processed.
 *  Before they are processed, intents can have two forms : 
 *      1. "Static" : when creating new intents (with the methods : "intentWith...")
 *      2. "Dynamic" (also named "navigation intent") : the intent contains a request for an already existing Intent in the history stack. It will contain all the elements in the above list AFTER it is processed.
 *
 *
 *            **---------------------------**
 *            **  HOW TO READ THE SCHEMAS  **
 *            **---------------------------**
 *
 *               +-- The Section (MCSectionViewController) the Intent is related to
 *               |       +-- A column represent an intent in the stack (with its related Section and View)
 *               |       |
 *               V       V
 * +--------+---- ----++---+---+---+---+---+---+---+---+---+---+-+-+
 * |        |SectionVC|| 1 | 1 | 1 | 2 | 2 | 1 | 1 | 3 | 3 | 3 | 3 |\
 * | Stack  +---------||---+---+---+---+---+---+---+---+---+---+---| >- Latest intent
 * |        | ViewVC  || 11| 12| 13| 21| 22| 21| 12| 31| 32| 34| 33|/
 * +--------+---- ----++- -+---+---+---+---+---+---+---+---+---+- -+
 *               ^        \_ From oldest intent to the lastest _/
 *               |
 *               +-- The View (MCViewController) the Intent is related to
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


/*            **-------------------------------------------------------**
 *            **  Schema for "newActivityWithAssociatedSectionNamed:"  **
 *            **-------------------------------------------------------**
 *
 *
 * Method used in example : "newActivityWithRelatedSectionName:Section3VC"
 *
 * +--------+---------++---+---+---+---+---+---+---+---+---+---+-+-+     +---+
 * |        |SectionVC|| 1 | 1 | 1 | 2 | 2 | 1 | 1 | 3 | 3 | 3 | 3 |     | 3 |
 * | Stack  +---------||---+---+---+---+---+---+---+---+---+---+---+ --> +---+
 * |        | ViewVC  || 11| 12| 13| 21| 22| 21| 12| 31| 32| 34| 33|     |   |
 * +--------+---------++---+---+---+---+---+---+---+---+---+---+---+     +---+
 *
 */

/*!
 * @function newActivityWithAssociatedSectionNamed
 * @discussion Sections without Views should be avoided.
 * @discussion Creates and return a new Activity. This Activity will not be related to any View, only a Section. Behavior has not been tested. 
 * @discussion Instead, we recommand creating a dummy MCSectionViewController sub-class and then create Activities related to this Section for your Views that can not be grouped in Sections.
 * @param sectionName       The Section the Activity will be related to
 */
+(MCIntent *) newActivityWithAssociatedSectionNamed: (NSString*) sectionName;

/*!
 * @function newActivityWithAssociatedSectionNamed andActivityInfos
 * @discussion Only used by the undo operation.
 * @discussion Creates and return a new Activity. This Activity will not be related to any View, only a Section. Behavior has not been tested.
 * @discussion Instead, we recommand creating a dummy MCSectionViewController sub-class and then create Activities related to this Section for your Views that can not be grouped in Sections.
 * @param sectionName       The Section the Activity will be related to
 * @param andSavedInstance  The Activity's savedInstance dictionary
 */
+(MCIntent *) newActivityWithAssociatedSectionNamed: (NSString*) sectionName
                                     andActivityInfos: (NSMutableDictionary*) activityInfos;

/*!
 * @function newActivityWithAssociatedSectionNamed andAnimation
 * @discussion Creates and return a new Activity. This Activity will not be related to any View, only a Section. Behavior has not been tested.
 * @discussion Instead, we recommand creating a dummy MCSectionViewController sub-class and then create Activities related to this Section for your Views that can not be grouped in Sections.
 * @param sectionName   The Section the Activity will be related to
 * @param animation     The animation to this Activity's Section when processed.
 * @discussion Prefered animations are ANIMATION_NOTHING, ANIMATION_PUSH, ANIMATION_POP, UIViewAnimationOptionTransitionCrossDissolve. Other UI transitions work.
 */
+(MCIntent *) newActivityWithAssociatedSectionNamed: (NSString*) name
                                         andAnimation: (UIViewAnimationOptions) animation;




/*            **--------------------------------------------------------------------**
 *            **  Schema for "newActivityWithAssociatedViewNamed: inSectionNamed:"  **
 *            **--------------------------------------------------------------------**
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
 * @function newActivityWithAssociatedViewNamed inSectionNamed
 * @discussion Creates and return a new Activity attributed to a Section and related to a View.
 * @param sectionName   The Section the Activity will be related with
 * @param viewName      The View the Activity will be related to
 */
+(MCIntent *) newActivityWithAssociatedViewNamed: (NSString*) viewName
                                    inSectionNamed: (NSString*) sectionName;

/*!
 * @function newActivityWithAssociatedViewNamed: inSectionNamed: andAnimation:
 * @discussion Creates and return a new Activity attributed to a Section and related to a View and with an animation.
 * @param sectionName   The Section the Activity will be related with
 * @param viewName      The View the Activity will be related to
 * @param animation     The animation to this Activity's View when processed. 
 * @discussion Prefered animations are ANIMATION_NOTHING, ANIMATION_PUSH, ANIMATION_POP, UIViewAnimationOptionTransitionCrossDissolve. Other UI transitions work.
 */
+(MCIntent *) newActivityWithAssociatedViewNamed: (NSString*)viewName
                                    inSectionNamed: (NSString*)sectionName
                                      andAnimation: (UIViewAnimationOptions)animation;


#pragma mark - Navigation Intents

#pragma mark - Push Methods


/*            **---------------------------------------**
 *            **  Schema for "pushActivityFromHistory" **
 *            **---------------------------------------**
 *
 * Inputs in example :
 *    - pushActivityFromHistoryByPosition: 6
 * or - pushActivityFromHistoryByName: @"View22VC"
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
 * @function pushActivityFromHistory
 * Push a specific Activity from the history stack to the top of the stack.
 * @discussion Push means that when found, the Activity will be removed from its position in the stack and placed on top of the stack.
 * @param ptrActivity Pointer to the Activity to push on top of the stack.
 * @return New pointer to the Activity, make sur to replace old one with this one.
 */
+(MCIntent *) pushActivityFromHistory: (MCActivity *) ptrToActivity;

/*!
 * @function pushActivityFromHistoryByPosition
 * Push an Activity to the top of the stack, given its position in the stack.
 * @discussion Push means that when found, the Activity will be removed from its position in the stack and placed on top of the stack.
 * @param positionInStack Activity's position in the stack. Position 1 = last Activity in the history stack. Has to be > 0.
 */
+(MCIntent *) pushActivityFromHistoryByPosition: (int) positionInStack;

/*!
 * @function pushActivityFromHistoryByName
 * Push an Activity to the top of the stack, given it's associated View's name.
 * @discussion Push means that when found, the Activity will be removed from its position in the stack and placed on top of the stack.
 * @discussion /!\ WARNING /!\ Because multiple Activities might have the same name, this method will find the first Activity matching the given name in the history stack and push it on top of the stack.
 * @param mcViewControllerName Name of the MCViewController (View) associated with the Activity to find.
 */
+(MCIntent *) pushActivityFromHistoryByName: (NSString *) mcViewControllerName;




#pragma mark - Pop methods

#pragma mark Pop to an Activity in History

/*            **-------------------------------------**
 *            **  Schema for "popToActivityInHistory"  **
 *            **-------------------------------------**
 *
 * Method used in example :
 *       - popToActivityInHistory: 6
 *   or  - popToActivityInHistory: @"View22VC"
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
 * @function popToActivityInHistory
 * Pop to a specific Activity in the history stack.
 * @discussion Pop means removing one by one each Activity in the history stack until finding the one it is looking for.
 * @param ptrActivity Pointer to the Activity to pop to.
 * @return New pointer to the Activity, make sur to replace old one with this one.
 */
+(MCIntent *) popToActivityInHistory: (MCActivity *) ptrToActivity;

/*!
 * @function popToActivityInHistoryByPosition
 * Pop to an Activity given its position in the stack.
 * @discussion Pop means removing one by one each Activity in the history stack until finding the one it is looking for.
 * @param positionInStack Activity's position in the stack. Position 1 = last Activity in the history stack. Has to be > 0.
 */
+(MCIntent *) popToActivityInHistoryByPosition: (int) positionInStack;

/*!
 * @function popToActivityInHistoryByPositionLast
 * Pop to the last Activity in the history stack.
 * @discussion Same as using popToActivityInHistoryByPosition:1
 */
+(MCIntent *) popToActivityInHistoryByPositionLast;

/*!
 * @function popToActivityInHistoryByName
 * Pop to an Activity, given it's associated View's name.
 * @discussion Pop means removing one by one each Activity in the history stack until finding the one it is looking for.
 * @discussion /!\ WARNING /!\ Because multiple Activities might have the same name, this method will find the first Activity matching the given name in the history stack and pop to it.
 * @param mcViewControllerName Name of the MCViewController (View) associated with the Activity to find.
 */
+(MCIntent *) popToActivityInHistoryByName: (NSString *) mcViewControllerName;




#pragma mark Pop to Sections' Root Activity


/*            **----------------------------------**
 *            **  Schema for "popToActivityRoot"  **
 *            **----------------------------------**
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
 * Infos : root section is Section1VC and the root View in this section is View11VC.
 *
 */

/*!
 * @function popToActivityRoot
 * Pop to the root Activity in the history stack.
 * @discussion Pop means removing one by one each Activity in the history stack until finding the one it is looking for (the root Activity here).
 */
+(MCIntent *) popToActivityRoot;




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
 * @function popToActivityRootInSectionCurrent
 * Pop to the root Activity of the current section in the history stack.
 * @discussion Pop means removing one by one each Activity in the history stack until finding the one it is looking for (the root Activity of the current section here).
 */
+(MCIntent *) popToActivityRootInSectionCurrent;




/*            **-----------------------------------------------**
 *            **  Schema for "popToActivityRootInSectionLast"  **
 *            **-----------------------------------------------**
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
 * @function popToActivityRootInSectionLast
 * Pop to the root Activity of the last section in the history stack.
 * @discussion Pop means removing one by one each Activity in the history stack until finding the one it is looking for (the root Activity of the last section here).
 */
+(MCIntent *) popToActivityRootInSectionLast;




/*            **------------------------------------------------**
 *            **  Schema for "popToActivityRootInSectionNamed"  **
 *            **------------------------------------------------**
 *
 *  Method used in example : "popToActivityRootInSectionNamed:@"Section1VC"
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
 * @function popToActivityRootInSectionNamed
 * Pop to the root Activity of the section with the given name.
 * @discussion Pop means removing one by one each Activity in the history stack until finding the one it is looking for (the root Activity of the given section).
 * /!\ WARNING /!\ This method will find the first Activity in the stack that is related to the given Section name and then find the root in the Section. If the Section appears again previously in the stack, it will not be reached. See header comments for a visual representation of this warning.
 * @param mcSectionViewControllerName Name of the MCSectionViewController (Section) associated with the Activity to find.
 */
+(MCIntent *) popToActivityRootInSectionNamed: (NSString *) mcSectionViewControllerName;




#pragma mark Pop to Sections' last Activity



/*            **-----------------------------------------------**
 *            **  Schema for "popToActivityLastInSectionLast"  **
 *            **-----------------------------------------------**
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
 * @function popToActivityLastInSectionLast
 * Pop to the root Activity of the current section in the history stack.
 * @discussion Pop means removing one by one each Activity in the history stack until finding the one it is looking for (the root Activity of the current section).
 */
+(MCIntent *) popToActivityLastInSectionLast;




/*            **------------------------------------------------**
 *            **  Schema for "popToActivityLastInSectionNamed"  **
 *            **------------------------------------------------**
 *
 * Method used in example : "popToActivityLastInSectionNamed:@"Section1VC"
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
 * @function popToActivityLastInSectionNamed
 * Pop to the last Activity (first encountered Activity when rewinding the stack) of the section with the given name.
 * @discussion Pop means removing one by one each Activity in the history stack until finding the one it is looking for.
 * /!\ WARNING /!\ This method will find the first Activity in the stack that is related to the given Section name. If the Section appears again previously in the stack, it will not be reached. See header comments for a visual representation of this warning.
 * @param mcSectionViewControllerName Name of the MCSectionViewController (Section) associated with the Activity to find.
 */
+(MCIntent *) popToActivityLastInSectionNamed: (NSString *) mcSectionViewControllerName;



#pragma mark - internal accessors

@property (strong, nonatomic, readonly) NSString *sectionName;
@property (strong, nonatomic, readonly) NSString *viewName;
@property (strong, nonatomic, readonly) MCStackRequestDescriptor *stackRequestDescriptor;

@end
