//
//  RBObjectModel.m
//  RecipeBook
//
//  Created by Matt Diephouse on 1/19/12.
//  Copyright (c) 2012 Matt Diephouse. All rights reserved.
//

#import "RBObjectModel.h"


#import "RBObjectModel_v001.h"
#import "RBObjectModel_v002.h"

@implementation RBObjectModel

//==================================================================================================
#pragma mark -
#pragma mark NSObject Methods
//==================================================================================================

- (id) init
{
    self = [super init];
    
    if (self)
    {
        self.versionIdentifiers = [NSSet setWithObject:NSStringFromClass([self class])];
    }
    
    return self;
}


//==================================================================================================
#pragma mark -
#pragma mark Public Methods
//==================================================================================================

+ (NSArray *) allVersions
{
    return [NSArray arrayWithObjects:
            [RBObjectModel_v001 new],
            [RBObjectModel_v002 new],
            nil];
}

+ (id) currentVersion
{
    return [RBObjectModel_v002 new];
}


@end
