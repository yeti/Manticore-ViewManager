//
//  MCViewManagerTests.m
//  ManticoreViewManager
//
//  Created by Philippe Bertin on 8/12/14.
//
//

#import <XCTest/XCTest.h>



/*!
 * This class tests all the methode when processing an intent.
 *
 * If (Targets -> MCViewManagerTests -> Apple LLVM 5.1 - Preprocessing -> Enable Foundation Assertions : YES)  : the tests WILL FAIL.
 *
 * If you turn Assertions OFF and it still doesn't work, try "edit scheme / Test / Build Configuration : release
 *
 */
@interface MCViewManagerTests : XCTestCase

@property (strong, nonatomic) MCActivity *activity0;
@property (strong, nonatomic) MCActivity *activity1;
@property (strong, nonatomic) MCActivity *activity2;
@property (strong, nonatomic) MCActivity *activity3;
@property (strong, nonatomic) MCActivity *activity4;
@property (strong, nonatomic) MCActivity *activity5;
@property (strong, nonatomic) MCActivity *activity6;
@property (strong, nonatomic) MCActivity *activity7;
@property (strong, nonatomic) MCActivity *activity8;
@property (strong, nonatomic) MCActivity *activity9;
@property (strong, nonatomic) MCActivity *activity10;
@property (strong, nonatomic) MCActivity *activity11;
@property (strong, nonatomic) MCActivity *activity12;

@end

@implementation MCViewManagerTests

- (NSMutableArray *)getHistoryStack
{
    return [[MCViewManager sharedManager] valueForKey:@"activityStack"];
}

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.

    [[MCViewManager sharedManager] setActivityStackSize:STACK_SIZE_UNLIMITED];
    
    
    MCIntent *intent0 = [MCIntent intentNewActivityWithAssociatedViewNamed:@"View10" inSectionNamed:@"Section1"];
    MCIntent *intent1 = [MCIntent intentNewActivityWithAssociatedViewNamed:@"View11" inSectionNamed:@"Section1"];
    MCIntent *intent2 = [MCIntent intentNewActivityWithAssociatedViewNamed:@"View12" inSectionNamed:@"Section1"];
    MCIntent *intent3 = [MCIntent intentNewActivityWithAssociatedViewNamed:@"View13" inSectionNamed:@"Section1"];
    MCIntent *intent4 = [MCIntent intentNewActivityWithAssociatedViewNamed:@"View21" inSectionNamed:@"Section2"];
    MCIntent *intent5 = [MCIntent intentNewActivityWithAssociatedViewNamed:@"View22" inSectionNamed:@"Section2"];
    MCIntent *intent6 = [MCIntent intentNewActivityWithAssociatedViewNamed:@"View21" inSectionNamed:@"Section2"];
    MCIntent *intent7 = [MCIntent intentNewActivityWithAssociatedViewNamed:@"View12" inSectionNamed:@"Section1"];
    MCIntent *intent8 = [MCIntent intentNewActivityWithAssociatedViewNamed:@"View12" inSectionNamed:@"Section1"];
    MCIntent *intent9 = [MCIntent intentNewActivityWithAssociatedViewNamed:@"View31" inSectionNamed:@"Section3"];
    MCIntent *intent10 = [MCIntent intentNewActivityWithAssociatedViewNamed:@"View32" inSectionNamed:@"Section3"];
    MCIntent *intent11 = [MCIntent intentNewActivityWithAssociatedViewNamed:@"View34" inSectionNamed:@"Section3"];
    MCIntent *intent12 = [MCIntent intentNewActivityWithAssociatedViewNamed:@"View33" inSectionNamed:@"Section3"];
    
    
    _activity0 = [[MCViewManager sharedManager] processIntent:intent0];
    _activity1 = [[MCViewManager sharedManager] processIntent:intent1];
    _activity2 = [[MCViewManager sharedManager] processIntent:intent2];
    _activity3 = [[MCViewManager sharedManager] processIntent:intent3];
    _activity4 = [[MCViewManager sharedManager] processIntent:intent4];
    _activity5 = [[MCViewManager sharedManager] processIntent:intent5];
    _activity6 = [[MCViewManager sharedManager] processIntent:intent6];
    _activity7 = [[MCViewManager sharedManager] processIntent:intent7];
    _activity8 = [[MCViewManager sharedManager] processIntent:intent8];
    _activity9 = [[MCViewManager sharedManager] processIntent:intent9];
    _activity10 = [[MCViewManager sharedManager] processIntent:intent10];
    _activity11 = [[MCViewManager sharedManager] processIntent:intent11];
    _activity12 = [[MCViewManager sharedManager] processIntent:intent12];

}

- (void)tearDown
{
    [[MCViewManager sharedManager] setValue:[NSMutableArray arrayWithCapacity:1] forKey:@"activityStack"];
    
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testRightStackSize
{
    XCTAssertTrue([self getHistoryStack].count == 13, @"HistoryStack Should initially contain 13");
}

- (void)testNewActivityEmptyOrBad
{
    // NOTHING
    MCIntent *intentPush = [[MCIntent alloc] init];
    MCActivity *activity = [[MCViewManager sharedManager] processIntent:intentPush];
    XCTAssertNil(activity, @"Should be nil when intent is empty");
    
    // VIEW NO SECTION NO DESCRIPTOR
    intentPush = [[MCIntent alloc] init];
    [intentPush setValue:@"View1" forKey:@"viewName"];
    activity = [[MCViewManager sharedManager] processIntent:intentPush];
    XCTAssertNil(activity, @"Should be nil when intent is empty");
    
    // DESCRIPTOR + VIEW + SECTION
    intentPush = [[MCIntent alloc] init];
    [intentPush setValue:@"Section1" forKey:@"sectionName"];
    [intentPush setValue:@"view1" forKey:@"viewName"];
    [intentPush setValue:[[MCStackRequestDescriptor alloc] init] forKey:@"stackRequestDescriptor"];
    activity = [[MCViewManager sharedManager] processIntent:intentPush];
    XCTAssertNil(activity, @"Should be nil when intent is empty");
    
    // DESCRIPTOR + VIEW
    intentPush = [[MCIntent alloc] init];
    [intentPush setValue:@"view1" forKey:@"viewName"];
    [intentPush setValue:[[MCStackRequestDescriptor alloc] init] forKey:@"stackRequestDescriptor"];
    activity = [[MCViewManager sharedManager] processIntent:intentPush];
    XCTAssertNil(activity, @"Should be nil when intent is empty");
    
    // DESCRIPTOR + SECTION
    intentPush = [[MCIntent alloc] init];
    [intentPush setValue:@"Section1" forKey:@"sectionName"];
    [intentPush setValue:[[MCStackRequestDescriptor alloc] init] forKey:@"stackRequestDescriptor"];
    activity = [[MCViewManager sharedManager] processIntent:intentPush];
    XCTAssertNil(activity, @"Should be nil when intent is empty");
}

- (void)testNewActivityWithSectionNoView
{
    MCIntent *intentPush = [MCIntent intentNewActivityWithAssociatedSectionNamed:@"Section1"];
    MCActivity *activity = [[MCViewManager sharedManager] processIntent:intentPush];
    
    NSMutableArray *historyStack = [self getHistoryStack];
    XCTAssertTrue(historyStack.count == 14, @"HistoryStack Should contain 13");
    XCTAssertEqualObjects([historyStack objectAtIndex:5], _activity5, @"Did not push correctly.");
    XCTAssertEqualObjects([historyStack objectAtIndex:13], activity, @"Did not push correctly.");
    
    XCTAssertEqual(((MCActivity*)[historyStack objectAtIndex:13]).associatedSectionName, @"Section1", @"Did not push correctly");
    XCTAssertNil(((MCActivity*)[historyStack objectAtIndex:13]).associatedViewName, @"Did not push correctly");
}


- (void)testNewActivityWithSectionAndView
{
    MCIntent *intentPush = [MCIntent intentNewActivityWithAssociatedViewNamed:@"View10" inSectionNamed:@"Section1"];
    MCActivity *activity = [[MCViewManager sharedManager] processIntent:intentPush];
    
    NSMutableArray *historyStack = [self getHistoryStack];
    XCTAssertTrue(historyStack.count == 14, @"HistoryStack Should contain 13");
    XCTAssertEqualObjects([historyStack objectAtIndex:5], _activity5, @"Did not push correctly.");
    XCTAssertEqualObjects([historyStack objectAtIndex:13], activity, @"Did not push correctly.");
    
    XCTAssertEqual(((MCActivity*)[historyStack objectAtIndex:13]).associatedSectionName, @"Section1", @"Did not push correctly");
    XCTAssertEqual(((MCActivity*)[historyStack objectAtIndex:13]).associatedViewName, @"View10", @"Did not push correctly");
}

#pragma mark - Push In History

- (void)testPushActivityFromHistory
{
    NSMutableArray *historyStack = [self getHistoryStack];
    
    MCIntent *intentPush = [MCIntent intentPushActivityFromHistory:_activity4];
    MCActivity *activity = [[MCViewManager sharedManager] processIntent:intentPush];
    
    
    XCTAssertTrue(historyStack.count == 13, @"HistoryStack Should contain 13");
    XCTAssertEqualObjects([historyStack objectAtIndex:4], _activity5, @"Did not push correctly.");
    XCTAssertEqualObjects([historyStack objectAtIndex:12], _activity4, @"Did not push correctly.");
    XCTAssertEqualObjects(activity, _activity4, @"Did not push correctly");
}

- (void)testPushActivityFromHistoryByPosition
{
    NSMutableArray *historyStack = [self getHistoryStack];
    
    MCIntent *intentPush = [MCIntent intentPushActivityFromHistoryByPosition:8];
    MCActivity *activity = [[MCViewManager sharedManager] processIntent:intentPush];
    
    
    XCTAssertTrue(historyStack.count == 13, @"HistoryStack Should contain 13");
    XCTAssertEqualObjects([historyStack objectAtIndex:4], _activity5, @"Did not push correctly.");
    XCTAssertEqualObjects([historyStack objectAtIndex:12], _activity4, @"Did not push correctly.");
    XCTAssertEqualObjects(activity, _activity4, @"Did not push correctly");
}


- (void)testPushActivityFromHistoryByName
{
    NSMutableArray *historyStack = [self getHistoryStack];
    
    MCIntent *intentPush = [MCIntent intentPushActivityFromHistoryByName:@"View21"];
    MCActivity *activity = [[MCViewManager sharedManager] processIntent:intentPush];
    
    XCTAssertTrue(historyStack.count == 13, @"HistoryStack Should contain 13");
    XCTAssertEqualObjects([historyStack objectAtIndex:4], _activity4, @"Did not push correctly.");
    XCTAssertEqualObjects([historyStack objectAtIndex:12], _activity6, @"Did not push correctly.");
    XCTAssertEqualObjects(activity, _activity6, @"Did not push correctly");
}


#pragma mark - Pop In History


- (void)testPopToActivityInHistory
{
    NSMutableArray *historyStack = [self getHistoryStack];
    
    MCIntent *intentPop = [MCIntent intentPopToActivityInHistory:_activity4];
    MCActivity *activity = [[MCViewManager sharedManager] processIntent:intentPop];
    
    XCTAssertTrue(historyStack.count == 5, @"HistoryStack Should contain 5");
    XCTAssertEqualObjects([historyStack objectAtIndex:4], _activity4, @"Did not push correctly.");
    XCTAssertEqualObjects(activity, _activity4, @"Did not push correctly");
    XCTAssertFalse([historyStack containsObject:_activity5], @"Did not push correctly");
    
    // Pop to non-existing activity in stack
    intentPop = [MCIntent intentPopToActivityInHistory:_activity6];
    activity = [[MCViewManager sharedManager] processIntent:intentPop];
    XCTAssertNil(activity, @"Activity should be nil");
    
    // Pop to same activity
    intentPop = [MCIntent intentPopToActivityInHistory:_activity4];
    activity = [[MCViewManager sharedManager] processIntent:intentPop];
    XCTAssertNil(activity, @"Activity should be nil");
}

- (void)testPopToActivityInHistoryByPosition
{
    NSMutableArray *historyStack = [self getHistoryStack];
    
    MCIntent *intentPush = [MCIntent intentPopToActivityInHistoryByPosition:8];
    MCActivity *activity = [[MCViewManager sharedManager] processIntent:intentPush];
    
    XCTAssertTrue(historyStack.count == 5, @"HistoryStack Should contain 5");
    XCTAssertEqualObjects([historyStack objectAtIndex:4], _activity4, @"Did not push correctly.");
    XCTAssertEqualObjects(activity, _activity4, @"Did not push correctly");
    XCTAssertFalse([historyStack containsObject:_activity5], @"Did not push correctly");
    
    // Pop too many
    intentPush = [MCIntent intentPopToActivityInHistoryByPosition:5];
    activity = [[MCViewManager sharedManager] processIntent:intentPush];
    XCTAssertNil(activity, @"Activity should be nil");
}

- (void)testPopToActivityInHistoryByPositionLast
{
    NSMutableArray *historyStack = [self getHistoryStack];
    
    MCIntent *intentPush = [MCIntent intentPopToActivityInHistoryByPositionLast];
    MCActivity *activity = [[MCViewManager sharedManager] processIntent:intentPush];
    
    XCTAssertTrue(historyStack.count == 12, @"HistoryStack Should contain 12");
    XCTAssertEqualObjects([historyStack objectAtIndex:11], activity, @"Did not push correctly.");
    XCTAssertEqualObjects(activity, _activity11, @"Did not push correctly");
    XCTAssertFalse([historyStack containsObject:_activity12], @"Did not push correctly");
}

- (void)testPopToActivityInHistoryByName
{
    NSMutableArray *historyStack = [self getHistoryStack];
    
    
    MCIntent *intentPop = [MCIntent intentPopToActivityInHistoryByName:@"View21"];
    
    MCActivity *activity = [[MCViewManager sharedManager] processIntent:intentPop];
    XCTAssertTrue(historyStack.count == 7, @"HistoryStack Should contain 7");
    XCTAssertEqualObjects([historyStack objectAtIndex:6], activity, @"Did not push correctly.");
    XCTAssertEqualObjects(activity, _activity6, @"Did not push correctly");
    XCTAssertFalse([historyStack containsObject:_activity7], @"Did not push correctly");
    
    // Re-pop to the same
    activity = [[MCViewManager sharedManager] processIntent:intentPop];
    XCTAssertNil(activity, @"Should be nil");
    
    // Pop to non-Existing View in stack
    intentPop = [MCIntent intentPopToActivityInHistoryByName:@"View31"];
    activity = [[MCViewManager sharedManager] processIntent:intentPop];
    XCTAssertNil(activity, @"Should be nil");
    
    // Pop to non-Existing Section (without view) in stack
    intentPop = [MCIntent intentPopToActivityInHistoryByName:@"Section1"];
    activity = [[MCViewManager sharedManager] processIntent:intentPop];
    XCTAssertNil(activity, @"Should be nil");
    
    // Now let's add a section without View in the stack
    activity = [[MCActivity alloc] initWithAssociatedSectionNamed:@"Section4"];
    [historyStack insertObject:activity atIndex:3];
    // And pop to it
    intentPop = [MCIntent intentPopToActivityInHistoryByName:@"Section4"];
    activity = [[MCViewManager sharedManager] processIntent:intentPop];
    XCTAssertTrue(historyStack.count == 4, @"HistoryStack Should contain 4");
    XCTAssertEqualObjects([historyStack objectAtIndex:2], _activity2, @"Did not push correctly.");
    XCTAssertFalse([historyStack containsObject:_activity3], @"Did not push correctly");
    
}


#pragma mark - Pop to Root

- (void)testPopToActivityRoot
{
    NSMutableArray *historyStack = [self getHistoryStack];
    
    MCIntent *intentPop = [MCIntent intentPopToActivityRoot];
    MCActivity *activity = [[MCViewManager sharedManager] processIntent:intentPop];
    
    XCTAssertTrue(historyStack.count == 1, @"HistoryStack Should contain 1");
    XCTAssertEqualObjects([historyStack objectAtIndex:0], activity, @"Did not push correctly.");
    XCTAssertEqualObjects(activity, _activity0, @"Did not push correctly");
    XCTAssertFalse([historyStack containsObject:_activity1], @"Did not push correctly");
}

- (void)testPopToActivityRootInSectionCurrent
{
    NSMutableArray *historyStack = [self getHistoryStack];
    
    MCIntent *intentPop = [MCIntent intentPopToActivityRootInSectionCurrent];
    MCActivity *activity = [[MCViewManager sharedManager] processIntent:intentPop];
    
    XCTAssertTrue(historyStack.count == 10, @"HistoryStack Should contain 10");
    XCTAssertEqualObjects([historyStack objectAtIndex:9], activity, @"Did not push correctly.");
    XCTAssertEqualObjects(activity, _activity9, @"Did not push correctly");
    XCTAssertFalse([historyStack containsObject:_activity10], @"Did not push correctly");
    
    // Re-doing it should return a Nil Activity
    intentPop = [MCIntent intentPopToActivityRootInSectionCurrent];
    activity = [[MCViewManager sharedManager] processIntent:intentPop];
    
    XCTAssertNil(activity, @"Activity should be nil at this point");
}

- (void)testPopToActivityRootInSectionLast
{
    NSMutableArray *historyStack = [self getHistoryStack];
    
    MCIntent *intentPop = [MCIntent intentPopToActivityRootInSectionLast];
    MCActivity *activity = [[MCViewManager sharedManager] processIntent:intentPop];
    
    XCTAssertTrue(historyStack.count == 8, @"HistoryStack Should contain 10");
    XCTAssertEqualObjects([historyStack objectAtIndex:7], activity, @"Did not push correctly.");
    XCTAssertEqualObjects(activity, _activity7, @"Did not push correctly");
    XCTAssertFalse([historyStack containsObject:_activity8], @"Did not push correctly");
}

- (void)testPopToActivityRootInSectionNamed
{
    NSMutableArray *historyStack = [self getHistoryStack];
    
    // TRY WITH SECTION 1
    MCIntent *intentPop = [MCIntent intentPopToActivityRootInSectionNamed:@"Section1"];
    MCActivity *activity = [[MCViewManager sharedManager] processIntent:intentPop];
    
    XCTAssertTrue(historyStack.count == 8, @"HistoryStack Should contain 8");
    XCTAssertEqualObjects([historyStack objectAtIndex:7], activity, @"Did not push correctly.");
    XCTAssertEqualObjects(activity, _activity7, @"Did not push correctly");
    XCTAssertFalse([historyStack containsObject:_activity8], @"Did not push correctly");
    
    
    // TRY WITH SECTION 2
    intentPop = [MCIntent intentPopToActivityRootInSectionNamed:@"Section2"];
    activity = [[MCViewManager sharedManager] processIntent:intentPop];
    
    XCTAssertTrue(historyStack.count == 5, @"HistoryStack Should contain 5");
    XCTAssertEqualObjects([historyStack objectAtIndex:4], activity, @"Did not push correctly.");
    XCTAssertEqualObjects(activity, _activity4, @"Did not push correctly");
    XCTAssertFalse([historyStack containsObject:_activity5], @"Did not push correctly");
}


#pragma mark - Pop to Last

- (void)testPopToActivityLastInSectionLast
{
    NSMutableArray *historyStack = [self getHistoryStack];
    
    MCIntent *intentPop = [MCIntent intentPopToActivityLastInSectionLast];
    MCActivity *activity = [[MCViewManager sharedManager] processIntent:intentPop];
    
    XCTAssertTrue(historyStack.count == 9, @"HistoryStack Should contain 9");
    XCTAssertEqualObjects([historyStack objectAtIndex:8], activity, @"Did not push correctly.");
    XCTAssertEqualObjects(activity, _activity8, @"Did not push correctly");
    XCTAssertFalse([historyStack containsObject:_activity9], @"Did not push correctly");
}

- (void)testPopToActivityLastInSectionNamed
{
    NSMutableArray *historyStack = [self getHistoryStack];
    
    // TRY WITH SECTION 1
    MCIntent *intentPop = [MCIntent intentPopToActivityLastInSectionNamed:@"Section1"];
    MCActivity *activity = [[MCViewManager sharedManager] processIntent:intentPop];
    
    XCTAssertTrue(historyStack.count == 9, @"HistoryStack Should contain 8");
    XCTAssertEqualObjects([historyStack objectAtIndex:8], activity, @"Did not push correctly.");
    XCTAssertEqualObjects(activity, _activity8, @"Did not push correctly");
    XCTAssertFalse([historyStack containsObject:_activity9], @"Did not push correctly");
    
    
    // TRY WITH SECTION 2
    intentPop = [MCIntent intentPopToActivityLastInSectionNamed:@"Section2"];
    activity = [[MCViewManager sharedManager] processIntent:intentPop];
    
    XCTAssertTrue(historyStack.count == 7, @"HistoryStack Should contain 5");
    XCTAssertEqualObjects([historyStack objectAtIndex:6], activity, @"Did not push correctly.");
    XCTAssertEqualObjects(activity, _activity6, @"Did not push correctly");
    XCTAssertFalse([historyStack containsObject:_activity7], @"Did not push correctly");
    
    
    // TRY WITH SECTION 2 AGAIN
    intentPop = [MCIntent intentPopToActivityLastInSectionNamed:@"Section2"];
    activity = [[MCViewManager sharedManager] processIntent:intentPop];
    
    XCTAssertNil(activity, @"Activity Should be Nil");
}

#pragma mark - Other methods

-(NSUInteger)testIsCurrentViewRootInSection
{
    XCTAssertFalse([[MCViewManager sharedManager] isCurrentViewRootInSection], @"Should not be root in Section");
    
    // Pop to activity root and make sure it's root
    MCIntent *intent = [MCIntent intentPopToActivityRootInSectionCurrent];
    [[MCViewManager sharedManager] processIntent:intent];
    XCTAssertTrue([[MCViewManager sharedManager] isCurrentViewRootInSection], @"Should be root in Section");
    
    // Pop to not root
    intent = [MCIntent intentPopToActivityLastInSectionLast];
    [[MCViewManager sharedManager] processIntent:intent];
    XCTAssertFalse([[MCViewManager sharedManager] isCurrentViewRootInSection], @"Should not be root in Section");
    
    // Pop to root
    intent = [MCIntent intentPopToActivityRoot];
    [[MCViewManager sharedManager] processIntent:intent];
    XCTAssertTrue([[MCViewManager sharedManager] isCurrentViewRootInSection], @"Should be root in Section");
}


@end
