//
//  RBObjectModel.m
//  RecipeBook
//
//  Created by Matt Diephouse on 1/19/12.
//  Copyright (c) 2012 Matt Diephouse. All rights reserved.
//

#import "RBObjectModel.h"


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
        NSAttributeDescription *recipeName = [NSAttributeDescription new];
        recipeName.name          = @"name";
        recipeName.attributeType = NSStringAttributeType;
        
        NSEntityDescription *recipe = [NSEntityDescription new];
        recipe.managedObjectClassName = @"RBRecipe";
        recipe.name       = @"Recipe";
        recipe.properties = [NSArray arrayWithObjects:
                             recipeName,
                             nil];
        
        self.entities = [NSArray arrayWithObjects:
                         recipe,
                         nil];
    }
    
    return self;
}


@end
