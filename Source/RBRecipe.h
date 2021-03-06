//
//  RBRecipe.h
//  RecipeBook
//
//  Created by Matt Diephouse on 1/21/12.
//  Copyright (c) 2012 Matt Diephouse. All rights reserved.
//

#import <CoreData/CoreData.h>


@class RBSource;

@interface RBRecipe : NSManagedObject

@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) RBSource *source;

@end
