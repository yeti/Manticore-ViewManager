//
//  MCStackRequestDescriptor.h
//  Pods
//
//  Created by Philippe Bertin on 8/7/14.
//
//

#import <Foundation/Foundation.h>

@interface MCStackRequestDescriptor : NSObject

/*
 *
 * "requestType"
 *      - "pop"     : when found, activity will be popped
 *      - "push"    : when found, activity will be pushed
 *
 * "requestCriteria"
 *      - "history" : History means looking at the stack as a whole.
 *      - "root"    : Root means the activity looked for is the root activity of a Section.
 *      - "last"    : Last means looking for the last activity that appeared in a given section.
 *
 * "requestInfo" :
 *      - (MCActivity*) : a pointer to the wanted activity
 *      - (NSString *)  : a string representing the Activity's associated View name
 *      - (NSNumber*)   : an int representing a position in the stack
 *
 */

/*!
 *  All currently supported scenarios :
 *
 *  type            criteria                               info
 *    |                 |                                    |
 *  +---+       +----------------+                      +------+------+
 *  |POP|-----> | From/In history+-----------------+-->  MCActivity * |
 *  +---+   +-> +----------------+                 |    +------+------+
 *          |                                      |
 *          |   +----------------+                 |    +-------------+
 *          +-> |Root in Section +------+----+-->  +-->  NSString *   |
 *  +----+  |   +----------------+      |    |     |    +-------------+
 *  |PUSH|--+                           |    |     |
 *  +----+  |   +----------------+      |    |     |    +-----+
 *          +-> |Last in Section +------+->  +-->  +-->  int  |
 *              +----------------+                      +-----+
 *
 *
 * Corresponding to the following methods :
 *
 *  pushActivityFromHistory:(intent)                
 *  pushActivityFromHistoryByName:(NSString)
 *  pushActivityFromHistoryByPosition:(int)
 *
 *  popToActivityInHistory:(intent)
 *  popToActivityInHistoryByName:(NSString)
 *  popToActivityInHistoryByPosition:(int)
 *  popToActivityInHistoryByPositionLast
 *
 *  popToActivityRoot
 *  popToActivityRootInSectionLast
 *  popToActivityRootInSectionCurrent
 *  popToActivityRootInSectionNamed:(NSString)
 *
 *  popToActivityLastInSectionLast
 *  popToActivityLastInSectionNamed:(NSString)
 *
 *
 */


typedef enum {
    POP,
    PUSH
}availableRequestType;



typedef enum {
    HISTORY,
    ROOT,
    LAST
}availableRequestCriteria;


@property (nonatomic, readonly) availableRequestType        requestType;
@property (nonatomic, readonly) availableRequestCriteria    requestCriteria;
@property (strong, nonatomic, readonly) NSObject*           requestInfos;


-(id)initWithRequestType:(availableRequestType)requestType
         requestCriteria:(availableRequestCriteria)requestCriteria
             requestInfo:(NSObject*)requestInfo;

@end
