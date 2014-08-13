//
//  MCActivity.m
//  Pods
//
//  Created by Philippe Bertin on 8/7/14.
//
//

#import "MCActivity.h"

@interface MCActivity ()

@property (strong, nonatomic, readwrite) NSString* associatedSectionName;
@property (strong, nonatomic, readwrite) NSString* associatedViewName;
@property (strong, nonatomic, readwrite) NSMutableDictionary* activityInfos;


@end



@implementation MCActivity


-(id)initWithAssociatedSectionNamed:(NSString *)sectionName
{
    if (self = [super init])
    {
        self.associatedSectionName = sectionName;
        self.activityInfos = [NSMutableDictionary dictionaryWithCapacity:2];
    }
    return self;
}

-(id)initWithAssociatedViewNamed:(NSString *)viewName
                  inSectionNamed:(NSString *)sectionName
{
    if (self = [super init])
    {
        self.associatedViewName = viewName;
        self.associatedSectionName = sectionName;
        self.activityInfos = [NSMutableDictionary dictionaryWithCapacity:2];
    }
    return self;
}



@end
