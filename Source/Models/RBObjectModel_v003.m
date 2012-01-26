//
//  RBObjectModel_v003.m
//  RecipeBook
//
//  Created by Matt Diephouse on 1/22/12.
//  Copyright (c) 2012 Matt Diephouse. All rights reserved.
//

#import "RBObjectModel_v003.h"


@implementation RBObjectModel_v003

//==================================================================================================
#pragma mark -
#pragma mark NSObject Methods
//==================================================================================================

- (id) init
{
    self = [super init];
    
    if (self)
    {
        // Entites
        
        NSEntityDescription *source = [NSEntityDescription new];
        source.managedObjectClassName = @"RBSource";
        source.name       = @"Source";
        
        NSEntityDescription *recipe = [NSEntityDescription new];
        recipe.managedObjectClassName = @"RBRecipe";
        recipe.name       = @"Recipe";
        
        // Source Attributes
        
        NSAttributeDescription *sourceName = [NSAttributeDescription new];
        sourceName.name          = @"name";
        sourceName.attributeType = NSStringAttributeType;
        
        // Recipe Attributes
        
        NSAttributeDescription *recipeName = [NSAttributeDescription new];
        recipeName.name          = @"name";
        recipeName.attributeType = NSStringAttributeType;
        
        // Source <---->> Recipe Relationship
        
        NSRelationshipDescription *sourceRecipes = [NSRelationshipDescription new];
        NSRelationshipDescription *recipeSource  = [NSRelationshipDescription new];
        sourceRecipes.name                = @"recipes";
        sourceRecipes.destinationEntity   = recipe;
        sourceRecipes.inverseRelationship = recipeSource;
        sourceRecipes.deleteRule          = NSNullifyDeleteRule;
        sourceRecipes.minCount            = 0;
        sourceRecipes.maxCount            = -1;
        recipeSource.name                 = @"source";
        recipeSource.destinationEntity    = source;
        recipeSource.inverseRelationship  = sourceRecipes;
        recipeSource.deleteRule = NSNullifyDeleteRule;
        recipeSource.minCount = 1;
        recipeSource.maxCount = 1;
        recipeSource.optional = YES;
        
        // Set properties and entities
        
        source.properties = [NSArray arrayWithObjects:
                             sourceName,
                             sourceRecipes,
                             nil];
        
        recipe.properties = [NSArray arrayWithObjects:
                             recipeName,
                             recipeSource,
                             nil];
        
        self.entities = [NSArray arrayWithObjects:
                         recipe,
                         source,
                         nil];
    }
    
    return self;
}


//==================================================================================================
#pragma mark -
#pragma mark RBObjectModel Methods
//==================================================================================================

- (NSMappingModel *) mappingModel
{
    NSExpression *allRecipesExpr = [NSExpression expressionWithFormat:@"FETCH(FUNCTION($manager, \"fetchRequestForSourceEntityNamed:predicateString:\" , \"Recipe\", \"TRUEPREDICATE\"), $manager.sourceContext, NO)"];
    // Recipe --> Source
    
    NSEntityMapping *recipeToSource = [NSEntityMapping new];
    recipeToSource.sourceEntityName      = @"Recipe";
    recipeToSource.destinationEntityName = @"Source";
    recipeToSource.mappingType           = NSCustomEntityMappingType;
    recipeToSource.entityMigrationPolicyClassName = @"RBPropertyToEntityPolicy";
    recipeToSource.userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                               @"source",   @"sourcePropertyName",
                               @"name",     @"destinationPropertyName",
                               nil];
    recipeToSource.sourceExpression = allRecipesExpr;
    
    // Recipe --> Recipe
    
    NSPropertyMapping *recipeToRecipe_name = [NSPropertyMapping new];
    recipeToRecipe_name.name = @"name";
    recipeToRecipe_name.valueExpression = [NSExpression expressionWithFormat:@"$source.name"];
    
    NSPropertyMapping *recipeToRecipe_source = [NSPropertyMapping new];
    recipeToRecipe_source.name = @"source";
    recipeToRecipe_source.valueExpression = [NSExpression expressionWithFormat:@"FUNCTION($manager, \"destinationInstancesForEntityMappingNamed:sourceInstances:\" , \"Recipe->Source\", $source)[0]"];
    
    NSEntityMapping *recipeToRecipe = [NSEntityMapping new];
    recipeToRecipe.sourceEntityName      = @"Recipe";
    recipeToRecipe.destinationEntityName = @"Recipe";
    recipeToRecipe.mappingType           = NSTransformEntityMappingType;
    recipeToRecipe.attributeMappings     = [NSArray arrayWithObjects:
                                            recipeToRecipe_name,
                                            recipeToRecipe_source,
                                            nil];
    recipeToRecipe.sourceExpression      = allRecipesExpr;
    
    NSMappingModel *mapping = [NSMappingModel new];
    mapping.entityMappings = [NSArray arrayWithObjects:
                              recipeToSource,
                              recipeToRecipe,
                              nil];
    return mapping;
}


@end
