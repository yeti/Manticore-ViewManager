#Welcome to Manticore MCViewManager



**MCViewManager** is here to fight against the complexity of managing View-Controllers in iOS. It will help you concentrate on the making of your View-Controllers and will take care of their management for you.    

It's extremely difficult to deal with a history stack of View-Controllers that contains multiple times the same View-Controller but with different Data associated with it.      
With MCViewManager, this problem is gone.

Plus, thanks to its internal structure, MCViewManager will help you manage your tabbed applications without any more constraints than any other application !!



##Overview

Inspired from the [Android activity lifecycle](http://developer.android.com/training/basics/activity-lifecycle/pausing.html), Manticore's main power comes from the use of **Activities** to manage the View-Controllers and their associated Data.

> It's important to note that manticore refers to `View-Controllers` as `Views` (or `Sections`)

Here is a schema that shows Manticore View Manager's main functionality. What's important to see is : 

  1. You make an intent (MCIntent methods) to create an Activity or to go to a specific one in the activity stack.
  2. You process the intent, Manticore deals with the stack of activities and makes the intent become an Activity
  3. `MCMainViewController` automatically loads the View corresponding to the Activity. Provided methods similar to `viewDidLoad` or `viewDidAppear` allow the View to retrieve the Data associated with the Activity.


![Schema](https://github.com/YetiHQ/MCViewManager/blob/master/Documentation/Activities_Logic.png "Intents And Activities")





##Installation


Installation using CocoaPods is really easy. Add this line to your Podfile then `pod install` :

    pod 'MCViewManager', :git => 'https://github.com/YetiHQ/MCViewManager'


If you do not wish to use CocoaPods, you may always do it the old way : download/clone the project and copy the files located in Pod/Classes into your project.         
Manticore-iosviewmanager does not require any external dependencies.    

If you wish to install the Example project, clone or download this project to your computer, then `pod install` in the terminal under `MCViewManager/Example`.



        
        
        

##Features

Features included with this release:

* Creation of Activities (and therefore Views) in 2 (two) lines of code
* Intents for navigation between activities with an extensive list of Pop and Push methods
* Easy transmission of data between Views
* Tabbed Applications made easy
* Well documented and commented








##Getting started : basic usage


#### Import Manticore

Importing `ManticoreViewFactory.h` will provide everything needed.

```objc
#import <ManticoreViewManager.h>
```


#### Create your Views

Let's create a simple application, composed of two Views in a Section. Sections have to sub-class *MCSectionViewController* and Views have to sub-class *MCViewController*. Create these classes with their associated .xib (nib). For now, think of a Section as a container for Views that are related.

```objc
// Section1VC.h 
@interface Section1VC : MCSectionViewController
@end

// View1VC.h
@interface View1VC : MCViewController
@end

// View2VC.h
@interface View2VC : MCViewController
@end

// And so on...
```

>When creating a Section (sub-class MCSectionViewController), you have to create a UIView that will hold the Section's Views. For now, make the UIView the size of the Screen. You then have to connect this UIView to the `innerView` attribute of the superclass (see gif).

![Schema](https://github.com/YetiHQ/MCViewManager/blob/master/Documentation/SectionsAddInnerView.gif "Section connect innerView")

#### Initialize
Create Manticore's MainViewController and add it to your application's window. We suggest doing this initialization process somewhere in `application:didFinishLaunchingWithOptions:` :


```objc
// You can use the "createViewController" method provided by Manticore to create the mainViewController
UIViewController* mainVC = [[MCViewManager sharedFactory] createViewController:VIEW_BUILTIN_MAIN];
[self.window setRootViewController:mainVC];
[mainVC.view setFrame:[[UIScreen mainScreen] bounds]];
```


#### Make an intent to create an Activity

Create an Activity (or more...) for each of your Views : make an Intent then process it.
    
```objc
// Make the intent 
MCIntent* intent = [MCIntent intentNewActivityWithAssociatedViewNamed:@"View1VC" inSectionNamed:@"Section1VC"];

// Process the intent to create the Activity and show its associated View
[[MCViewModel sharedModel] processIntent:intent];
```



-------------------------------------------


##Sections and Views

>Once again, it's important to note that manticore refers to `View-Controllers` as `Views` or `Sections`

####Understanding the concept

When developping an application, you will usually want to group the Views into Sections. If you are developing a regular application, try to group views that you feel are connected in a way, that would often navigate between each others. If you are developping a tabbed application, each tab will have it's own Section.   
Think as Sections as "containers" for related Views.

Sections can also be shown without views in order to create single-level hierarchy,
but it's a better design to create one Section with multiple Views.     
If you feel a View-Controller could not be linked to any other, then create a Section with no Views. Then, be sure to never associate any View to this Section.



As an example, if you were to develop a social app, you could want to group the Views like this :

* Logins : all the VCs related to the login process (welcome vc, login vc, reset-password vc...)
* Profile : all the VCs related to managing the user's profile
* Feeds : all the VCs related to showing the different feeds
* and so on ...

The **Sections** would here be `Logins` `Profile` `Feeds`.    
The **Views** would be all the ViewControllers inside these Sections.   
    

Both Views and Sections are sub-classes of `UIViewController`.




#### Staying organized

We highly suggest making macros for all your Sections and Views' names.       
This way, it will help to avoid making mistakes when making intents on these Views. (Although MCViewManager will Assert errors). Plus, if you ever rename a class, you only have to change the name on the macro instead of multiple times. Most of all... auto-completion is always nice ;)

```objc
// Define the Sections
#define SECTION_FIRST   @"myFirstSectionVC"
#define SECTION_SECOND  @"mySecondSectionVC"
#define SECTION_LAST    @"myLastSectionVC"

// Define the Views
#define VIEW_1      @"View1VC"
#define VIEW_2      @"View2VC"
#define VIEW_3      @"View3VC"
```

You can then create the intents using the macros :

```objc
MCIntent* intent = [MCIntent intentNewActivityWithAssociatedViewNamed:@"View_1" inSectionNamed:"Section_FIRST];
```



##Activities

####Definition

An activity is a single, focused thing that the user can do. An activity may contain data, and is associated with a View-Controller. There are two cases possible :

1. The Activity is associated with a View in a Section
2. The Activity is only associated with a Section

Activities are managed by MCViewManager. You have to make intents to either : create them or resume them by bringing them on top of the stack.


###Activity Lifecycle (example of full lifecycle)

1. Create an intent for a new Activity
2. Set up the intent
3. Process the Intent to become an Activity
4. View gets loaded (View associated with Activity)
5. New Intent processed (Another activity)
6. Later, intent to bring back Activity


#####1. Create an intent for a new Activity

At this point, you create an intent that is either associated with a Section or with a View in a Section.

```objc
// Intent for a  new Activity with only an associated Section
MCIntent *intent = [MCIntent intentNewActivityWithAssociatedSectionNamed: sectionName];

// Intent for a new Activity associated with a View, in a Section
MCIntent *intent = [MCIntent intentNewActivityWithAssociatedViewNamed: viewName
                                                        inSectionNamed: sectionName;
```

#####2. Setup the intent

Now that you have the intent, you may set it up.    

* Set the `transitionAnimationStyle`
  Valid animation styles include all valid `UIViewAnimationTransition` and the following constants, listed below:
  * `ANIMATION_NOTHING`
  * `ANIMATION_PUSH`
  * `ANIMATION_PUSH_LEFT`
  * `ANIMATION_POP`
  * `ANIMATION_POP_LEFT`
  * `ANIMATION_SLIDE_FROM_BOTTOM`
  * `ANIMATION_SLIDE_FROM_TOP`
  
  ```objc
  // If you do not set the animation style, it is set to ANIMATION_NOTHING
  intent.transitionAnimationStyle = ANIMATION_NOTHING
  ```
  
* Add objects to the intent's `userInfos` dictionary. These objects will be added to the activity's `activityInfos` dictionary.

#####3. Process the Intent to become an Activity




#####4. View gets loaded (View associated with Activity)
#####5. New Intent processed (Another activity)
#####6. Later, intent to bring back Activity



###Making an intent

You have two reasons to make intents :

1. Create a new Activity
2. Find a previous Activity (an activity that has already been processed an is therefore on the stack, if stack enabled)

When you want to switch to a View, you have to **make an intent**, using the **MCIntent class**. Do not instanciate intents directly, instead use the provided class methods.
    
Here is a list of the most commom intents :

1. Intent to create a new Activity

    ```objc
    // Intent for a  new Activity with only an associated Section
    +(MCIntent *) intentNewActivityWithAssociatedSectionNamed: (NSString*) sectionName;

    // Intent for a new Activity associated with a View, in a Section
    +(MCIntent *) intentNewActivityWithAssociatedViewNamed: (NSString*) viewName
                                            inSectionNamed: (NSString*) sectionName;
    ```

2. Intent to find an Activity in the activity Stack

    ```objc
    // Intent to push a past activity
    +(MCIntent *) intentPushActivityFromHistory: (MCActivity *) ptrToActivity;
    +(MCIntent *) intentPushActivityFromHistoryByPosition: (int) positionInStack;
    +(MCIntent *) intentPushActivityFromHistoryByName: (NSString *) mcViewControllerName;

    // Intent to pop to a past activity
    +(MCIntent *) intentPopToActivityInHistory: (MCActivity *) ptrToActivity;
    +(MCIntent *) intentPopToActivityInHistoryByPosition: (int) positionInStack;
    +(MCIntent *) intentPopToActivityInHistoryByPositionLast;
    +(MCIntent *) intentPopToActivityInHistoryByName: (NSString *) mcViewControllerName;

    +(MCIntent *) intentPopToActivityRoot;
    
    // These methods are useful when you have created Sections
    // First (Root) in Section
    +(MCIntent *) intentPopToActivityRootInSectionCurrent;
    +(MCIntent *) intentPopToActivityRootInSectionLast;
    +(MCIntent *) intentPopToActivityRootInSectionNamed: (NSString *) mcSectionViewControllerName;
    // Last in Section
    +(MCIntent *) intentPopToActivityLastInSectionLast;
    +(MCIntent *) intentPopToActivityLastInSectionNamed: (NSString *) mcSectionViewControllerName;
    
    ```



####Transitionning to an Activity

After you have created your Intent, simply process it using the unique method provided by MCViewManager :

```objc
[[MCViewModel sharedModel] processIntent:intent];
```








A view transition happens when a new intent is assigned to `setCurrentSection:`.

    MCIntent* intent = [MCIntent intentWithSectionName:@"YourSectionViewController"];
    [intent setAnimationStyle:UIViewAnimationOptionTransitionFlipFromLeft];
    [[MCViewModel sharedModel] setCurrentSection:intent];

Valid animation styles include all valid UIViewAnimations and the following constants, listed below:

* `ANIMATION_NOTHING`
* `ANIMATION_PUSH`
* `ANIMATION_POP`
* `UIViewAnimationOptionTransitionFlipFromLeft`
* `UIViewAnimationOptionTransitionFlipFromRight`
* ...

`UIViewAnimation` run for 0.25 s and `ANIMATION_` run for 0.5 s. 


### Sending messages between activities

#### Sending

Custom instructions can be assigned for the receiving view's `onResume:`.

    MCIntent* intent = ...;
    [[intent savedInstanceState] setObject:@"someValue" forKey:@"yourKey"];
    [[intent savedInstanceState] setObject:@"anotherValue" forKey:@"anotherKey"];
    // ...
    [[MCViewModel sharedModel] setCurrentSection:intent];

#### Receiving

The events `onResume:` and `onPause:` are called on each MCViewController and MCSectionViewController
when the intent is fired. If the section stays the same and the view changes, both the section and
view receive `onResume` and `onPause` events.

When a view is restored, saved intent information can be loaded using:

    -(void)onResume:(MCIntent *)intent {
        NSObject* someValue = [intent.savedInstanceState objectForKey:@"yourKey"];
        NSObject* anotherValue = [intent.savedInstanceState objectForKey:@"anotherKey"];

        // ...

        // ensure the following line is called, especially for MCSectionViewController
        [super onResume:intent];
    }    

### View state

View controllers are cached on first load and reused throughout the application lifetime.
Application state should be loaded to `[intent savedInstanceState]` when `onResume:` is fired.
Modified view controller state should be saved `onPause:` when using the history stack.

The first time a view controller is loaded, `onCreate` is fired once for non-GUI setup. 
This event, however, is skipped if the view controller is loaded directly from MCViewFactory.

Cached view controllers can be flushed from memory with the following call:

    [[MCViewModel sharedModel] clearViewCache];

View factory
------------

Sometimes a developer wishes to show view controllers without using intents. In this case,
a dummy section should be created and subviews added inside. Then, the subviews are created
directly using:

    [[MCViewFactory sharedFactory] createViewController:@"MyViewController"]

`createViewController:` is a low-level function that does not provide caching, `onCreate`, 
`onResume`, and `onPause` events. This factory method can be used to load nested view controllers wherever and whenever you want.

History stack
-------------

A history stack for a back button can be configured:

* No history stack, i.e., no back button using:

    `[MCViewModel sharedModel].stackSize = STACK_SIZE_DISABLED;`

* Infinite history stack:

    `[MCViewModel sharedModel].stackSize = STACK_SIZE_UNLIMITED;`

* Bounded history stack, which is useful if you know beforehand how many views you can go:

    `[MCViewModel sharedModel].stackSize = 5; // 1 current + 4 history`


Fire an intent to navigate back in the history stack:

    if ([MCViewModel sharedModel].historyStack.count > 1){
        [MCViewModel sharedModel].currentSection = [MCIntent intentPreviousSectionWithAnimation:ANIMATION_POP];
    }

Or you can be more explicit by using `SECTION_LAST`:

    if ([MCViewModel sharedModel].historyStack.count > 1){
        [MCViewModel sharedModel].currentSection = [MCIntent intentWithSectionName:SECTION_LAST andAnimation:ANIMATION_POP];
    }

The history stack can be completely flushed before a new section is shown, which you want to do every once in a while to reduce memory consumption:

    [[MCViewModel sharedModel] clearHistoryStack];
    [[MCViewModel sharedModel] setCurrentSection:[MCIntent intentWithSectionName:...]];

Customizing the main window
---------------------------

The basic *MCMainViewController* shows a black window. If you want to override this window, for example, to show an application logo, you are able to do so:

1. Create `MCMainViewController.xib` file in XCode.
2. Have the `xib` File Owner be subclass `MCMainViewController`.
3. Connect the UIView to the File Owner's `view`.
4. When registering your views in code, add the following line:
    `[factory registerView:VIEW_BUILTIN_MAIN];`

Error dialog box
----------------

Manticore iOS View Factory comes with a built in error message view controller. To override the built in appearance and layout, 
create MCErrorViewController.xib and assign its file owner to subclass MCErrorViewController. 

Error messages are presented with a title label, message label, and button to dismiss the view controller. Error messages 
are not placed on the history stack, thus do not interfere with the navigation of your application.

### Showing error messages

To show error messages:

    [[MCViewModel sharedModel] setErrorTitle:@"Some Title" andDescription:"@Your message here"];

### Customizing the error window

The basic *MCErrorViewController* shows a grey window with a title, message body, and Dismiss button. If you want to override this window with your own look and feel:

1. Create `MCErrorViewController.xib` file in XCode.
2. Have the `xib` File Owner be a subclass of `MCErrorViewController`.
3. Connect the UIView to the File Owner's `view`.
4. Add a UILabel and connect it to `titleLabel`
5. Add a UILabel and connect it to `descripLabel`
6. Add a UIButton and set its *Touch Up Inside* to `dismissError:` action.
7. When registering your views in code, add the following line:
    `[factory registerView:VIEW_BUILTIN_ERROR];`

Screen overlays
---------------

Screen overlays are useful for giving instructions to the user. Screen overlays are implemented as UIImage resources embedded in the application. To show a screen overlay, call the following:

    [MCViewModel sharedModel].screenOverlay = @"some-image";

The string `@"some-image"` should be an image that is compatible with `[UIImage imageNamed:@"some-image"]`.

If the screen overlay is assigned several times, only the most recently overlay is shown.

### Displaying a sequence of overlays

Manticore iOS supports showing multiple screen overlays. When one overlay is dismissed, another overlay is shown until all of them are seen.

    [MCViewModel sharedModel].screenOverlays = @[@"image-1", @"image-2", @"image-3"];

### iPhone 4 and iPhone 5 overlays

Manticore iOS supports different overlays for iPhone 4 and iPhone 5. iPhone 5 overlays use the same name with a special suffix `_5`, which is added automatically. You should name your images as such:

* `some-image.png`
* `some-image_5.png`

Compiler settings
-----------------

Define `DEBUG` in compile settings to show debugger messages. `NSAssert` messages are unaffected by this setting.

##Release notes

###Release 0.1.0

* Refactoring :
  * Now comply with ARC
  * No more iVar direct manipulation
  * `MCViewFactory` and `MCViewModel` merged into `MCViewManager` 
  * No need to register the MCViewControllers anymore
  * Small improvements on keeping model & controller separated
  
* Renaming : 
  * `MCIntent` becomes `MCActivity` to conform with android model and to make more sense
  
* Class changes :
  * MCViewManager :
    * Removed `registerView: andNibName:` function
    * Removed `MCViewManagerEntry` (upper function needed it)
    
  * MCActivity :
    * Section name included in dictionary
    * New choices of intents
    * `viewName` becomes `associatedViewName`
    * `sectionName` becomes `associatedSectionName`
    * `animationStyle` becomes `transitionAnimationStyle`
    * `savedInstanceState` becomes `activityInfos`

* Depreciated :
  * MCViewManager's `setCurrentSection` replaced by `processIntent`
  * 

* Bug fixes :
  * Pop transition from a section's view to previous section's last opened view. Bug would cause the "new" view to appear on top of lastView when transitioning causing weird undesired effect.  


### Previous releases

0.0.9: added helper intent for navigating to the previous screen

0.0.8: added screen overlays

0.0.7: solve a bug where fast switching between activities would cause all activities to disappear

0.0.6: debug messages are written to the console log to ensure `onPause:` and `onResume:` superclass are called

0.0.5: sections and views are properly resized and fitted to the parent

0.0.4: first stable release

Known issues
------------

* CocoaPods and .xib files: "A signed resource has been added, modified, or deleted" error for CocoaPods with .xib 
  files happens the second time when an app is run. 

  This issue has been documented:
  [https://github.com/CocoaPods/CocoaPods/issues/790](https://github.com/CocoaPods/CocoaPods/issues/790)

  Add the script `rm -rf ${BUILT_PRODUCTS_DIR}` to the Pre-actions of the Build stage of your application's Scheme.

* You'll implement `onResume` on a MCViewController but it doesn't get called. You probably overrode `onResume` on MCSectionViewController without calling `[super onResume:intent]`.
