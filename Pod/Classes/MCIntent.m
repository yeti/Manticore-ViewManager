/*
 MCActivity.m
 Manticore View Manager
 
 Created by Richard Fung on 9/19/12.
 Reworked, refactored and commented by Philippe Bertin on August 1, 2014
 
 Copyright (c) 2014 Yeti LLC. All rights reserved.

 */

#import "MCIntent.h"


@interface MCIntent ()

@property (strong, nonatomic, readwrite) NSString *sectionName;
@property (strong, nonatomic, readwrite) NSString *viewName;
@property (strong, nonatomic, readwrite) MCStackRequestDescriptor *stackRequestDescriptor;

@property (strong, nonatomic, readwrite) NSMutableDictionary   *userInfos;

@end



@implementation MCIntent

@synthesize transitionAnimationStyle;

#pragma mark - Class methods


#pragma mark Section without view


+(MCIntent *) intentNewActivityWithAssociatedSectionNamed: (NSString*)sectionName
{
    MCIntent* newActivity = [[MCIntent alloc] initWithAssociatedSectionNamed:sectionName];
    return newActivity;
}

+(MCIntent *) intentNewActivityWithAssociatedSectionNamed: (NSString*)sectionName
                                         andAnimation:(UIViewAnimationOptions)animation
{
    MCIntent* newActivity = [[MCIntent alloc] initWithAssociatedSectionNamed:sectionName];
    [newActivity setTransitionAnimationStyle:animation];
    return newActivity;
}

+(MCIntent *) intentNewActivityWithAssociatedSectionNamed:(NSString*)sectionName
                                     andActivityInfos:(NSMutableDictionary*)activityInfos
{
    MCIntent* newActivity = [[MCIntent alloc] initWithAssociatedSectionNamed:sectionName
                                                          andActivityInfos:activityInfos];
    return newActivity;
}


#pragma mark Section with view

+(MCIntent *) intentNewActivityWithAssociatedViewNamed:(NSString*)viewName
                                    inSectionNamed:(NSString*)sectionName
{
    MCIntent* newActivity = [[MCIntent alloc] initWithAssociatedViewNamed:viewName
                                                           inSectionNamed:sectionName];
    return newActivity;
}

+(MCIntent *) intentNewActivityWithAssociatedViewNamed:(NSString*)viewName
                                  inSectionNamed:(NSString*)sectionName
                                    andAnimation:(UIViewAnimationOptions)animation
{
    MCIntent* newActivity = [[MCIntent alloc] initWithAssociatedViewNamed:viewName
                                                           inSectionNamed:sectionName];
    [newActivity setTransitionAnimationStyle:animation];
    return newActivity;
}


#pragma mark Dynamic Push Activities

+(MCIntent *) intentPushActivityFromHistory: (MCActivity *) ptrToActivity
{
    NSAssert(ptrToActivity != nil, @"%s : given pointer to activity is nil", __func__);
    
    MCIntent* newActivity = [[MCIntent alloc] initIntentRequestType:PUSH
                                                    requestCriteria:HISTORY
                                                           userInfo:ptrToActivity];
    return newActivity;
}


+(MCIntent *)intentPushActivityFromHistoryByPosition:(int)positionInStack
{
    NSAssert((positionInStack > 0), @"%s : positionInStack can not be %i", __func__, positionInStack);
    
    NSNumber *numberPosition = [NSNumber numberWithInt:positionInStack];
    MCIntent *newActivity = [[MCIntent alloc] initIntentRequestType:PUSH
                                                    requestCriteria:HISTORY
                                                           userInfo:numberPosition];
    return newActivity;
}

+(MCIntent *)intentPushActivityFromHistoryByName:(NSString *)mcViewControllerName
{
    NSAssert(NSClassFromString(mcViewControllerName), @"%s : %@ does not exist.", __func__, mcViewControllerName);
    
    MCIntent *newActivity = [[MCIntent alloc] initIntentRequestType:PUSH
                                                    requestCriteria:HISTORY
                                                           userInfo:mcViewControllerName];
    return newActivity;
}


#pragma mark Dynamic Pop Activities in history

+(MCIntent *)intentPopToActivityInHistory:(MCActivity *)ptrToActivity
{
    NSAssert(ptrToActivity != nil, @"%s : given pointer to activity is nil", __func__);
    
    MCIntent* newActivity = [[MCIntent alloc] initIntentRequestType:POP
                                                    requestCriteria:HISTORY
                                                           userInfo:ptrToActivity];
    return newActivity;
}

+(MCIntent *)intentPopToActivityInHistoryByPosition:(int)positionInStack
{
    NSAssert((positionInStack > 0), @"%s : positionInStack can not be %i", __func__, positionInStack);
    
    NSNumber *numberPosition = [NSNumber numberWithInt:positionInStack];
    MCIntent *newActivity = [[MCIntent alloc] initIntentRequestType:POP
                                                    requestCriteria:HISTORY
                                                           userInfo:numberPosition];
    return newActivity;

}

+(MCIntent *)intentPopToActivityInHistoryByPositionLast
{
    NSNumber *numberPosition = [NSNumber numberWithInt:1];
    MCIntent *newActivity = [[MCIntent alloc] initIntentRequestType:POP
                                                    requestCriteria:HISTORY
                                                           userInfo:numberPosition];
    return newActivity;
}

+(MCIntent *)intentPopToActivityInHistoryByName:(NSString *)mcViewControllerName
{
    NSAssert(NSClassFromString(mcViewControllerName), @"%s : %@ does not exist.", __func__, mcViewControllerName);
    
    MCIntent *newActivity = [[MCIntent alloc] initIntentRequestType:POP
                                                    requestCriteria:HISTORY
                                                           userInfo:mcViewControllerName];
    return newActivity;
}


#pragma mark Dynamic Pop Activities to root in Section

// popToActivityRoot is special as the number can not be known.
// Therefore, it is assigned number : -1.
//
+(MCIntent *)intentPopToActivityRoot
{
    NSNumber *numberPosition = [NSNumber numberWithInt:-1];
    MCIntent *newActivity = [[MCIntent alloc] initIntentRequestType:POP
                                                    requestCriteria:ROOT
                                                           userInfo:numberPosition];
    return newActivity;
}

+(MCIntent *)intentPopToActivityRootInSectionCurrent
{
    NSNumber *numberPosition = [NSNumber numberWithInt:0];
    MCIntent *newActivity = [[MCIntent alloc] initIntentRequestType:POP
                                                    requestCriteria:ROOT
                                                           userInfo:numberPosition];
    return newActivity;
}

+(MCIntent *)intentPopToActivityRootInSectionLast
{
    NSNumber *numberPosition = [NSNumber numberWithInt:1];
    MCIntent *newActivity = [[MCIntent alloc] initIntentRequestType:POP
                                                    requestCriteria:ROOT
                                                           userInfo:numberPosition];
    return newActivity;
}

+(MCIntent *)intentPopToActivityRootInSectionNamed:(NSString *)mcSectionViewControllerName
{
    NSAssert(NSClassFromString(mcSectionViewControllerName), @"%s : %@ does not exist.", __func__, mcSectionViewControllerName);
    
    MCIntent *newActivity = [[MCIntent alloc] initIntentRequestType:POP
                                                    requestCriteria:ROOT
                                                           userInfo:mcSectionViewControllerName];
    return newActivity;
}


#pragma mark Dynamic Pop Activities to last in Section

+(MCIntent *)intentPopToActivityLastInSectionLast
{
    // Section last is 1 (current = 0)
    NSNumber *numberPosition = [NSNumber numberWithInt:1];
    MCIntent *newActivity = [[MCIntent alloc] initIntentRequestType:POP
                                                    requestCriteria:LAST
                                                           userInfo:numberPosition];
    return newActivity;
}

+(MCIntent *)intentPopToActivityLastInSectionNamed:(NSString *)mcSectionViewControllerName
{
    NSAssert(NSClassFromString(mcSectionViewControllerName), @"%s : %@ does not exist.", __func__, mcSectionViewControllerName);
    
    MCIntent *newActivity = [[MCIntent alloc] initIntentRequestType:POP
                                                requestCriteria:LAST
                                                           userInfo:mcSectionViewControllerName];
    return newActivity;
}


#pragma mark - Private initialization methods

-(id) initWithAssociatedSectionNamed: (NSString*)sectionName
{
    NSAssert(NSClassFromString(sectionName), @"%s : Section %@ could not be found", __func__, sectionName);
    
    if (self = [super init])
    {
        self.transitionAnimationStyle = UIViewAnimationTransitionNone;
        self.userInfos = [NSMutableDictionary dictionaryWithCapacity:4];
        self.sectionName = sectionName;
        self.stackRequestDescriptor = nil;
    }
    return self;
}

-(id) initWithAssociatedViewNamed: (NSString*)viewName
                   inSectionNamed: (NSString*)sectionName
{
    NSAssert(NSClassFromString(viewName), @"%s : View %@ could not be found", __func__, viewName);
    NSAssert(NSClassFromString(sectionName), @"%s : Section %@ could not be found", __func__, sectionName);
    
    if (self = [super init])
    {
        self.transitionAnimationStyle = UIViewAnimationTransitionNone;
        self.userInfos = [NSMutableDictionary dictionaryWithCapacity:4];
        self.viewName = viewName;
        self.sectionName = sectionName;
        self.stackRequestDescriptor = nil;
        
    }
    return self;
}

-(id) initWithAssociatedSectionNamed: (NSString*)sectionName
                    andActivityInfos: (NSMutableDictionary*)activityInfos
{
    NSAssert(NSClassFromString(sectionName), @"%s : Section %@ could not be found", __func__, sectionName);
    
    if (self = [super init])
    {
        self.transitionAnimationStyle = UIViewAnimationTransitionNone;
        self.userInfos = [NSMutableDictionary dictionaryWithDictionary:activityInfos];
        self.sectionName = sectionName;
        self.stackRequestDescriptor = nil;
    }
    
    return self;
}

/*!
 * Initialize an intent requesting an activity : an intent that contains all the information for finding an Activity in the history stack.
 *
 * @param activityType      Either "pop" or "push". These are the two supported types by Manticore. When found, the Activity will either be pushed or popped on top of the stack.
 * @param searchCriteria    Can be "history", "root" or "last". History means looking at the stack as a whole. Root means the activity looked for is the root activity of a Section. Last means looking for the last activity that appeared in a given section.
 * @param userInfo          Currently supported userInfo types are : (MCActivity*), (NSString *), and ints represented by (NSNumber*).
 *
 */
-(id) initIntentRequestType:(availableRequestType)requestType
            requestCriteria:(availableRequestCriteria)requestCriteria
                   userInfo:(NSObject *)requestInfo
{
    if (self = [super init])
    {
        self.transitionAnimationStyle = UIViewAnimationTransitionNone;
        self.userInfos = [NSMutableDictionary dictionaryWithCapacity:4];
        self.stackRequestDescriptor = [[MCStackRequestDescriptor alloc] initWithRequestType:requestType
                                                                            requestCriteria:requestCriteria
                                                                                requestInfo:requestInfo];
    }
    
    return self;
}


-(NSString *) description {
    if (!_viewName && _sectionName)
        return [NSString stringWithFormat:@"MCIntent associated with section : %@ \n dictionary=%@", _sectionName, _userInfos];
    else if (_viewName && _sectionName)
        return [NSString stringWithFormat:@"MCIntent in section %@, associated with view %@ \n dictionary=%@", _sectionName, _viewName, _userInfos];

    return [NSString stringWithFormat:@"MCIntent with stack request type %u - criteria %u - info %@", _stackRequestDescriptor.requestType, _stackRequestDescriptor.requestCriteria, [_stackRequestDescriptor.requestInfos description]];
}

@end
