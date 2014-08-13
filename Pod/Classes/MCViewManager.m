//
//  MCViewFactory.m
//  Manticore iOSViewManager
//
//  Created by Philippe Bertin on August 1, 2014
//  Copyright (c) 2014 Yeti LLC. All rights reserved.
//

#import "MCViewManager.h"
#import "MCMainViewController.h"
#import <QuartzCore/QuartzCore.h>


// ref. http://stackoverflow.com/questions/923706/checking-if-a-nib-or-xib-file-exists
#define AssertFileExists(path) NSAssert([[NSFileManager defaultManager] fileExistsAtPath:path], @"Cannot find the file: %@", path)
#define AssertNibExists(file_name_string) AssertFileExists([[NSBundle mainBundle] pathForResource:file_name_string ofType:@"nib"])



#pragma mark
#pragma mark - MCViewManager class

@interface MCViewManager ()


/*!
 * Error dictionary observed by MCMainViewController
 */
@property(nonatomic, strong) NSDictionary *errorDict;


/*!
 * Pointer to the current Activity, observed by MCMainViewController
 */
@property(atomic, strong) MCActivity *currentActivity;


/*!
 * Activities history stack
 */
@property(nonatomic, strong, readwrite) NSMutableArray *historyStack;


@end


@implementation MCViewManager


@synthesize screenOverlay;
@synthesize screenOverlays;


#pragma mark - Initialization

-(id)init{
    if (self = [super init]){
        _stackSize = 0;
        [self clearHistoryStack];
    }
    return self;
}


+(MCViewManager *)sharedManager
{
    static MCViewManager* sharedManager = nil;
	static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        sharedManager = [[MCViewManager alloc] init];
    });
    return sharedManager;
}


#pragma mark - View-Controllers related


-(UIViewController*)createViewController:(NSString*)sectionOrViewName
{
    // Get the class from string
    Class class = NSClassFromString(sectionOrViewName);
    
    // Assert the class exists and the nib file exists
    NSAssert(class != nil, @"You tried to instanciate a Class that does not exists : %@. Class must exist.", sectionOrViewName);
    
    // Assert the nib file exists
    AssertNibExists(sectionOrViewName);
    
    // Create the viewController
    UIViewController* vc = [[class alloc] initWithNibName:sectionOrViewName bundle:nil] ;
  
#ifdef DEBUG
    NSLog(@"Created a view controller %@", [vc description]);
#endif
    
  return vc;
}


/*!
 *
 * 1. We have to either find the activity of create it (and deal with historyStack)
 *
 * 2. Populate the activity with new activityInfos from intent
 *
 * 3. Set the activity as new current Activity
 *
 */
-(MCActivity *)processIntent: (MCIntent *)intent
{
    // 1.
    MCActivity *activity = [self loadOrCreateActivityWithIntent:intent];
    if (!activity)
        return nil;
    
    // 2.
    [activity.activityInfos addEntriesFromDictionary:[intent activityInfos]];
    activity.transitionAnimationStyle = intent.transitionAnimationStyle;
    
    // 3.
    [self setCurrentActivity:activity];
    
    return activity;
}



#pragma mark -


- (void) clearHistoryStack
{
    _historyStack = [NSMutableArray arrayWithCapacity:_stackSize];
}


- (void) clearViewCache
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"MCMainViewController_flushViewCache" object:self];
}


#pragma mark -

-(void) setErrorTitle:(NSString*) title andDescription:(NSString*) description
{
    if (title == nil)
        title = @"";
    
    if (description == nil)
        description = @"";
    
    [self setErrorDict: [NSDictionary dictionaryWithObjects:@[title, description] forKeys:@[@"title", @"description"]]];
}

#pragma mark - Setters / Getters

-(void)setStackSize:(int)stackSize
{
    // Verify stackSize if >= 0
    NSAssert(stackSize >= 0, @"Stack size can not be less than 0, you tried to set it at %i", stackSize);
    _stackSize = stackSize;
    
    //TODO : if stackSize < currentStackSize remove from stack
}


-(int)historyStackCount
{
    return (int)_historyStack.count;
}


#pragma mark - Load and create Activities

/*!
 *
 * This method will create a new Activity if intent was create with [MCIntent newActivity...] and therefore contains an associated section (and usually an associated view too) and no stackRequestDescriptor. 
 *
 * This method will load the activity from the stack if the intent contains a stackRequestDescriptor. It will try to find the Activity corresponding to the descriptor, deal with the stack and return this activity.
 *
 * Stack only has to be managed when an activity is created.
 *
 */
-(MCActivity *)loadOrCreateActivityWithIntent:(MCIntent *)intent
{
    if (!intent)
        return nil;
    
    MCActivity *activity = nil;
    
    if (!intent.stackRequestDescriptor && intent.sectionName)
    {
        activity = [self createActivityWithIntent:intent];
        [self addActivityOnTopOfStack:activity];
    }
    
    else if (intent.stackRequestDescriptor && !intent.sectionName && !intent.viewName)
    {
        NSAssert((_stackSize != 1), @"Stack size can not be disabled (=1) when trying to pop or push");
        NSAssert((_historyStack.count > 1), @"Stack needs at least 2 Activies in stack (including current) when trying to pop or push");
        
        // See if push of pop method wanted and call appropriate method.
        switch (intent.stackRequestDescriptor.requestType)
        {
            case POP:
                activity = [self findAndPopToActivityOnStackWithIntent:intent];
                break;
                
            case PUSH:
                activity = [self findAndPushActivityOnTopOfStackWithIntent:intent];
                break;
                
            default:
                break;
        }
        
    }
    
    return activity;
}

/*!
 * Intent to a new Activity. This method creates it, puts it on top of the stack and return it.
 * 
 * @param intent The intent containing information for creating a new Activity.
 * @return The newly created activity.
 *
 */
-(MCActivity *)createActivityWithIntent:(MCIntent *)intent
{
    MCActivity *activity = nil;
    
    // If intent does not have a viewName then instantiate a Section Activity
    if (!intent.viewName)
    {
        activity = [[MCActivity alloc] initWithAssociatedSectionNamed:intent.sectionName];
    }
    else{
        activity = [[MCActivity alloc] initWithAssociatedViewNamed:intent.viewName
                                                    inSectionNamed:intent.sectionName];
    }
    return activity;
}


/*!
 * Intent contains a stackRequestDescriptor with a Push type. This method will try to find the activity corresponding to the given descriptor, then push it on top of the stack.
 *
 * @param intent The intent containing information for finding the activity in the stack.
 * @return The found activity or nil if not found. It will create an assertion anyway.
 *
 */
-(MCActivity *)findAndPushActivityOnTopOfStackWithIntent:(MCIntent *)intent
{
    // RequestInfo
    NSObject *info = intent.stackRequestDescriptor.requestInfos;
    
    // Init with position in stack = -1 : not found.
    NSInteger foundPositionInStack = -1;
    
    
    switch (intent.stackRequestDescriptor.requestCriteria)
    {
        case HISTORY:
            if (info == nil)
            {
                NSAssert(false, @"%s : MCError, put a ticket on GitHub. Can not find an Activity to push without requestInfo", __func__);
            }
            else if ([info isKindOfClass:[NSNumber class]])
            {
                foundPositionInStack = [self positionOfActivityInHistoryByPosition:(NSNumber*)info];
            }
            else if ([info isKindOfClass:[NSString class]])
            {
                foundPositionInStack = [self positionOfActivityInHistoryByName:(NSString*)info];
            }
            else if ([info isKindOfClass:[MCActivity class]])
            {
                foundPositionInStack = [self positionOfActivityInHistory:(MCActivity*)info];
            }
            break;
            
        default:
            // As of this version, pushing is available with criteria "history" only.
            NSAssert(false, @"%s : MCError, put a ticket on GitHub. Can not find an Activity to push with criteria other than HISTORY yet", __func__);
            break;
    }
    
    
    NSAssert(foundPositionInStack != 0, @"%s : Can not push current intent", __func__, intent);
    NSAssert(foundPositionInStack > 0, @"%s : Could not find activity corresponding to intent : %@", __func__, intent);
    
    // Find and remove activity at position
    MCActivity *activity = [_historyStack objectAtIndex:foundPositionInStack];
    [_historyStack removeObjectAtIndex:foundPositionInStack];
    
    // Push on top of stack
    [_historyStack addObject:activity];
    
    return activity;
}


/*!
 * Intent contains a stackRequestDescriptor with a Pop type. This method will try to find the activity corresponding to the given descriptor, then pop each Activities until this one.
 *
 * @param intent The intent containing information for finding the activity in the stack.
 * @return The found activity or nil if not found. It will create an assertion anyway.
 *
 */
-(MCActivity *)findAndPopToActivityOnStackWithIntent:(MCIntent *)intent
{
    // RequestInfo
    NSObject *info = intent.stackRequestDescriptor.requestInfos;
    
    // Position in stack = -1 : not found.
    NSInteger foundPositionInStack = -1;
    
    switch (intent.stackRequestDescriptor.requestCriteria)
    {
        case HISTORY:
            if (info == nil)
            {
                NSAssert(false, @"%s : MCError, put a ticket on GitHub. Can not find an Activity without requestInfo", __func__);
            }
            else if ([info isKindOfClass:[NSNumber class]])
            {
                foundPositionInStack = [self positionOfActivityInHistoryByPosition:(NSNumber*)info];
            }
            else if ([info isKindOfClass:[NSString class]])
            {
                foundPositionInStack = [self positionOfActivityInHistoryByName:(NSString*)info];
            }
            else if ([info isKindOfClass:[MCActivity class]])
            {
                foundPositionInStack = [self positionOfActivityInHistory:(MCActivity*)info];
            }
            break;
            
        case ROOT:
            if (info == nil)
            {
                NSAssert(false, @"%s : MCError, put a ticket on GitHub. Can not find an Activity without requestInfo", __func__);
            }
            else if ([info isKindOfClass:[NSNumber class]])
            {
                foundPositionInStack = [self positionOfActivityRootInSection:(NSNumber*)info];
            }
            else if ([info isKindOfClass:[NSString class]])
            {
                foundPositionInStack = [self positionOfActivityRootInSectionNamed:(NSString*)info];
            }
            break;

            
        case LAST:
            if (info == nil)
            {
                NSAssert(false, @"%s : MCError, put a ticket on GitHub. Can not find an Activity without requestInfo", __func__);
            }
            else if ([info isKindOfClass:[NSNumber class]])
            {
                foundPositionInStack = [self positionOfActivityLastInSection:(NSNumber*)info];
            }
            else if ([info isKindOfClass:[NSString class]])
            {
                foundPositionInStack = [self positionOfActivityLastInSectionNamed:(NSString*)info];
            }
            break;

        
        default:
            NSAssert(false, @"%s : MCError, put a ticket on GitHub.", __func__);
            break;
    }
    
    // Make sure position is between [0;_historyStack.count-2]
    if (foundPositionInStack == _historyStack.count-1)
    {
        NSLog(@"%s : Can not push current intent", __func__);
        return nil;
    }
    else if (foundPositionInStack < 0)
    {
        NSLog(@"%s : Could not find activity corresponding to intent : %@", __func__, [intent description]);
        return nil;
    }
    
    // Find activity
    MCActivity *activity = [_historyStack objectAtIndex:foundPositionInStack];

    // Remove all activities until foundPosition
    while (_historyStack.count > (foundPositionInStack+1)) {
        [_historyStack removeLastObject];
    }
    
    return activity;
}

#pragma mark Dealing with history stack when creating Activity

/*!
 * This method adds the acivity on top of the stack and then checks the stackSize and deal with adding/removing Activities from the stack if necessary.
 *
 * STACK_SIZE_DISABLED = 1 ; STACK_SIZE_UNLIMITED = 0 .
 *
 * @param activity Activity to put on top of the stack.
 *
 */
-(void)addActivityOnTopOfStack:(MCActivity *)activity
{
    // Stack disabled, no saving on stack : return
    if (_stackSize == STACK_SIZE_DISABLED)
        return;
    
    // Add activity on top of the stack
    [_historyStack addObject:activity];
    
    // Now check if adding the activity made historyStack too big
    if (_stackSize != STACK_SIZE_UNLIMITED)
    {
        NSAssert(_stackSize > 0, @"stack size must be positive");
        
        if (_historyStack.count > _stackSize)
        {
            // Remove first object to keet the stack bounded by stackSize.
            [_historyStack removeObjectAtIndex:0];
        }
    }
    

}


#pragma mark - Methods to find position in stack
// These methods do not depend on the fact that it is pushed/popped

#pragma mark In history

/*!
 * Position -1 = not found
 */
-(NSInteger)positionOfActivityInHistory:(MCActivity *)ptrToActivity
{
    for (NSInteger i=_historyStack.count-1; i>=0; i--)
    {
        if ([_historyStack objectAtIndex:i] == ptrToActivity)
            return i;
    }
    // Not found
    return -1;
}

/*!
 * Given position (positionFromLast) symmetrically at opposite position from center of historyStack.
 */
-(NSInteger)positionOfActivityInHistoryByPosition:(NSNumber *)positionFromLast
{
    NSInteger position = _historyStack.count - [positionFromLast integerValue] - 1;
    return position;
}

/*!
 * Check every viewName (then sectionName is no viewName) for given viewName.
 * @return Position of first occurence found
 */
-(NSInteger)positionOfActivityInHistoryByName:(NSString *)viewName
{
    for (NSInteger i=_historyStack.count-1; i>=0; i--)
    {
        MCActivity *activity = [_historyStack objectAtIndex:i];
        if (activity.associatedViewName)
        {
            if ([activity.associatedViewName isEqualToString:viewName])
                return i;
        } else
        {
            if ([activity.associatedSectionName isEqualToString:viewName])
                return i;
        }
        
    }
    // Not found
    return -1;
}

#pragma mark Root in Section


/*!
 * Given the sectionPosition (currentSection=0, lastSection=1..), this method will find the root intent in this section.
 */
-(NSInteger)positionOfActivityRootInSection:(NSNumber *)sectionPosition
{
    // Special case : -1 means we want the root activity on stack (position 0 in stack)
    if ([sectionPosition intValue] == -1)
        return 0;
    
    NSInteger foundPosition = 0;
    NSInteger sectionCounter = [sectionPosition integerValue];
    NSInteger numberOfSectionChanges = 0;
    
    NSString *currentSectionName = ((MCActivity *)[_historyStack lastObject]).associatedSectionName;
    
    for (NSInteger i = _historyStack.count -1; i>=0; i--)
    {
        MCActivity *activity = [_historyStack objectAtIndex:i];
        
        // Check if changed section
        if (![activity.associatedSectionName isEqualToString:currentSectionName])
        {
            sectionCounter--;
            numberOfSectionChanges ++;
            currentSectionName = activity.associatedSectionName;
            
            if (sectionCounter < 0)
            {
                return i+1;
            }
        }
    }
    
    // We make sure we didn't find any root but the one is the good section
    if (numberOfSectionChanges >= [sectionPosition intValue])
    {
        return foundPosition;
    }
    else return -1;
}

/*!
 *
 * Finds the root Activity in the given Section (first occurence of section observed)
 *
 */
-(NSInteger)positionOfActivityRootInSectionNamed:(NSString *)sectionName
{
    NSInteger foundPosition = -1;
    bool foundSection = false;
    
    for (NSInteger i=_historyStack.count-1; i>=0; i--)
    {
        MCActivity *activity = [_historyStack objectAtIndex:i];
        
        // When section is found
        if ([activity.associatedSectionName isEqualToString:sectionName])
        {
            foundPosition = i;
            foundSection = true;
        }
        // When section changes after found
        else if (foundSection)
        {
            return foundPosition;
        }
    }
    
    return foundPosition;
}



#pragma mark Last in Section

/*!
 *
 * Given the sectionPosition (lastSection=1..), this method will find the last intent in this section. Due to the nature of the "Last", this method can not find lastInCurrentSection. (Instead use : positionOfActivityInHistory(1)).
 *
 */
-(NSInteger)positionOfActivityLastInSection:(NSNumber *)sectionPosition
{
    NSAssert([sectionPosition intValue] >=0, @"%s : Put a ticket on Github, sectionPosition cannot be @u", __func__, [sectionPosition intValue]);
    
    NSInteger numberOfSectionChanges = 0;
    NSString *currentSectionName = ((MCActivity *)[_historyStack lastObject]).associatedSectionName;
    
    for (NSInteger i = _historyStack.count -1; i>=0; i--)
    {
        MCActivity *activity = [_historyStack objectAtIndex:i];
        
        if (![activity.associatedSectionName isEqualToString:currentSectionName])
        {
            numberOfSectionChanges++;
            currentSectionName = activity.associatedSectionName;
            
            // Test if we reached the good section
            if (numberOfSectionChanges == [sectionPosition intValue])
            {
                return i;
            }
        }
    }

    return -1;
}



/*!
 *
 * Finds the last Activity in the given Section (first occurence of section observed)
 *
 */
-(NSInteger)positionOfActivityLastInSectionNamed:(NSString *)sectionName
{
    // Make sure sectionName is different from current Section
    if ([((MCActivity*)[_historyStack objectAtIndex:_historyStack.count-1]).associatedSectionName isEqualToString:sectionName])
    {
        NSLog(@"%s : Due to the nature of this method, it is not possible to use ActivityLastInSectionNamed(nameOfTheCurrentSection). It is required that the Section to go to (\"sectionName\") is different from the current Section.", __func__);
        return -1;
    }
    
    for (NSInteger i=_historyStack.count-1; i>=0; i--)
    {
        MCActivity *activity = [_historyStack objectAtIndex:i];
        
        // When section is found
        if ([activity.associatedSectionName isEqualToString:sectionName])
        {
            return i;
        }
    }
    return -1;
}

@end
