//
//  MCStackRequestDescriptor.m
//  Pods
//
//  Created by Philippe Bertin on 8/7/14.
//
//

#import "MCStackRequestDescriptor.h"


@interface MCStackRequestDescriptor ()

@property (nonatomic, readwrite) availableRequestType requestType;
@property (nonatomic, readwrite) availableRequestCriteria requestCriteria;
@property (strong, nonatomic, readwrite) NSObject *requestInfos;

@end

@implementation MCStackRequestDescriptor

-(id)initWithRequestType:(availableRequestType)requestType
         requestCriteria:(availableRequestCriteria)requestCriteria
             requestInfo:(NSObject*)requestInfo
{
    if (self = [super init])
    {
        _requestType = requestType;
        _requestCriteria = requestCriteria;
        _requestInfos = requestInfo;
        
        [self verifyEntries];
    }
    return self;
}

-(void)verifyEntries
{
    // Test for pop/push
    NSAssert((_requestType == POP||_requestType == PUSH), @"%s : MCIntent can only create pop or push request. %u is not supported yet.", __func__, _requestType);
    
    //Test for history/root/last
    NSAssert((_requestCriteria == HISTORY||_requestCriteria == ROOT||_requestCriteria == LAST), @"%s : MCIntent can only create history, root or last request criterias. %u is not supported yet.", __func__, _requestCriteria);
    
    //Test for UserInfo
    //TODO
}

@end
