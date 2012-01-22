//
//  RBObjectModel_v002.m
//  RecipeBook
//
//  Created by Matt Diephouse on 1/21/12.
//  Copyright (c) 2012 Matt Diephouse. All rights reserved.
//

#import "RBObjectModel_v002.h"


@implementation RBObjectModel_v002

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
        
        NSAttributeDescription *recipeSource = [NSAttributeDescription new];
        recipeSource.name          = @"source";
        recipeSource.attributeType = NSStringAttributeType;
        
        NSEntityDescription *recipe = [NSEntityDescription new];
        recipe.managedObjectClassName = @"RBRecipe";
        recipe.name       = @"Recipe";
        recipe.properties = [NSArray arrayWithObjects:
                             recipeName,
                             recipeSource,
                             nil];
        
        self.entities = [NSArray arrayWithObjects:
                         recipe,
                         nil];
    }
    
    return self;
}


@end
