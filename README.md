#Welcome to Manticore iOS View Manager



##Overview

**Manticore-iosviewmanager** is a ViewController Management pattern for all iOS apps. It aims at making the creation of iOS applications easier, by not having to care about the View-Controllers' management.      

**manticore-iosviewmanager** will help in the making of any type of application although its two-level hierarchical view controller structure design is ideal for creating tabbed applications.      


**Manticore-iosviewmanager** was inspired by the [Android activity lifecycle](http://developer.android.com/training/basics/activity-lifecycle/pausing.html).


**Simplicity is key :**

1. Make an intent to create a VC,to go to a specific VC, to pop the last 3 VCs... possibilities are endless.
2. Process the intent with the help of a unique method.
3. Relax and let manticore do the hard work of managing the View-Controllers for you !


##Installation


Installation using CocoaPods is really easy. Add this line to your Podfile then `pod install` :

    pod 'MCViewManager', :git => 'https://github.com/YetiHQ/MCViewManager'


If you do not wish to use CocoaPods, you may always do it the old way : download/clone the project and copy the files located in Pod/Classes into your project.        
Manticore-iosviewmanager does not require any external dependencies.

##Features

Features included with this release:

* Two-level hierarchical view controller
* Intents to switch between activities, similar to Android intents
* Easy transmission of data between Manticore View-Controllers (MCViewController and MCSectionViewController)
* Static navigation between view-controllers using their names
* Dynamic navigation between view-controllers using the history stack



##Getting started : basic usage

-----
**Important note :** In Manticore, `Sections` and `Views` are `ViewControllers`.

-----

###### Import Manticore
Wherever you are using Manticore, importing `ManticoreViewFactory.h` will provide your file with all the necessary classes. 

```objc
#import <ManticoreViewManager.h>
```


###### Create your View-Controllers : Sub-class *MCSectionViewController* or *MCViewController*

We will create one section with two views. Section have to sub-class *MCSectionViewController* and views have to sub-class *MCViewController*. Create these classes with their .xib (nib) associated.

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


###### Initialize
Assign Manticore's MainViewController to your application's window. We suggest doing this initialization process somewhere in `application:didFinishLaunchingWithOptions:` :


```objc
UIViewController* mainVC = [[MCViewFactory sharedFactory] createViewController:VIEW_BUILTIN_MAIN];
[self.window setRootViewController:mainVC];
[mainVC.view setFrame:[[UIScreen mainScreen] bounds]];
```


###### Start showing your first section and view
Still in "application:didFinishLaunchingWithOptions:"
    
```objc
// Make an intent
MCIntent* intent = [MCIntent intentWithSectionName:@"Section1VC" andViewName:@"View1VC];

// Process the intent when you are ready to switch to the next view-controller
[[MCViewModel sharedModel] processIntent:intent];
```

-------------


##Sections and Views

#####Understanding the concept

When developping an application you will usually want to group the View-Controllers. As an example, if you were to develop a social app, you could want to group the VCs into these :

* Logins : all the VCs related to the login process (welcome vc, login vc, reset-password vc...)
* Profile : all the VCs related to managing the user's profile
* Feeds : all the VCs related to showing the different feeds
* and so on ...

The **Sections** would here be `Logins` `Profile` `Feeds`.    
The **Views** would be all the VCs inside these groups( -> sections).   
    
Sections can be seen as a way of organizing your application's views (or as tabs in a tabbed application).
Both are sub-classes of `UIViewController`.


##### Using a tabbed application

**Sections** should correspond to user interface's tabs and **views** should correspond to the views inside a tab.

Sections can also be shown without views in order to create single-level hierarchy,
but it's a better design to create one section with multiple views.

NOTE: I haven't tested a single-level hierarchy with all sections and no views.




##### Stay organized !

We highly suggest making macros for all your sections and views' names. You can do so in the appModel class if you have one, or in a separate header file.  
This way, it will help to avoid making mistakes when making intents on these View-Controllers. Plus, if you ever rename a class, you only have to change the name on the macro instead of multiple times. Most of all... auto-completion is always nice ;)

```objc
// Define the Sections
#define SECTION_FIRST   @"myFirstSectionVC"
#define SECTION_SECOND  @"mySecondSectionVC"
#define SECTION_LAST    @"myLastSectionVC"

// Define the Views
#define VIEW_LOGIN      @"myLoginVC"
#define VIEW_FEEDS      @"myFeedsVC"
#define VIEW_PROFILE    @"myProfileVC"
```

You can then process the intents using the macros :

```objc
MCIntent* intent = [MCIntent intentWithSectionName:SECTION_FIRST andViewName:VIEW_LOGIN];

[[MCViewModel sharedModel] processIntent:intent];
```



##Intents


###Making an intent

When you want to switch from one View-Controller to another, you have to *make an intent*, using the **MCIntent class**. Do not instanciate intents directly, instead use the provided class methods. These provide many ways for creating intents to go to the right View-Controller (or to create it).   
    
Here is a list of all possible intents :

1. Intent to create a new Section or View in Section. 
   When intent is processed, the related View-Controller will be added to the history stack.   
   
   >| View1 | View2 | &nbsp;&nbsp;  &#10549;  
   >| View1 | View2 | newView |  

    ```objc
    // You should avoid creating section without view
    +(id) intentWithSectionName: (NSString*) name;

    // Most commonly used method. Creates a View, associated with a Section.
    +(id) intentWithSectionName: (NSString*) sectionName andViewName: (NSString*) viewName;
    ```

2. Intent to find an intent in the history stack and POP to it.
   (go back in history stack until finding the one : popping others while parsing the stack)

   >| View1 | **View2** | View3 | View4 |    
   >| View1 | **View2** | View3 |  &nbsp;&nbsp;  &#10550;    
   >| View1 | **View2**   &nbsp;&nbsp;  &#10550;     

    ```objc
    // You should avoid creating section without view
    +(id) pop: (NSString*) name;
    ```

###Transition to the intent



### Sending an intent

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
