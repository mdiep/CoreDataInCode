//
//  RBPropertyToEntityPolicy.m
//  RecipeBook
//
//  Created by Matt Diephouse on 1/24/12.
//  Copyright (c) 2012 Matt Diephouse. All rights reserved.
//

#import "RBPropertyToEntityPolicy.h"


@implementation RBPropertyToEntityPolicy

//==================================================================================================
#pragma mark -
#pragma mark NSEntityMigrationPolicy
//==================================================================================================

- (BOOL)beginEntityMapping:(NSEntityMapping *)mapping manager:(NSMigrationManager *)manager error:(NSError **)error
{
    manager.userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                        [NSMutableDictionary dictionary], @"objects",
                        nil];
    return YES;
}

- (BOOL) createDestinationInstancesForSourceInstance:(NSManagedObject *)source
                                       entityMapping:(NSEntityMapping *)mapping
                                             manager:(NSMigrationManager *)manager
                                               error:(NSError **)error
{
    NSString *sourcePropertyName = [mapping.userInfo objectForKey:@"sourcePropertyName"];
    NSString *destPropertyName   = [mapping.userInfo objectForKey:@"destinationPropertyName"];
    
    id value = [source valueForKey:sourcePropertyName];
    
    // See if this object has already been created
    NSMutableDictionary *objects = [manager.userInfo objectForKey:@"objects"];
    NSManagedObject     *dest    = [objects valueForKey:value];
    if (!dest)
    {
        dest = [NSEntityDescription insertNewObjectForEntityForName:mapping.destinationEntityName
                                             inManagedObjectContext:manager.destinationContext];
        [dest setValue:value forKey:destPropertyName];
        [objects setValue:dest forKey:value];
    }
    
    [manager associateSourceInstance:source
             withDestinationInstance:dest
                    forEntityMapping:mapping];
    
    return YES;
}

- (BOOL) createRelationshipsForDestinationInstance:(NSManagedObject *)dInstance 
                                     entityMapping:(NSEntityMapping *)mapping 
                                           manager:(NSMigrationManager *)manager 
                                             error:(NSError **)error
{
    return YES;
}


@end
