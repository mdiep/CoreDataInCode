//
//  RBObjectModel.h
//  RecipeBook
//
//  Created by Matt Diephouse on 1/19/12.
//  Copyright (c) 2012 Matt Diephouse. All rights reserved.
//

#import <CoreData/CoreData.h>


@interface RBObjectModel : NSManagedObjectModel

+ (NSArray *) allVersions;
+ (id) currentVersion;

@property (strong, readonly) NSMappingModel *mappingModel;

@end
