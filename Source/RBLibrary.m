//
//  RBLibrary.m
//  RecipeBook
//
//  Created by Matt Diephouse on 1/19/12.
//  Copyright (c) 2012 Matt Diephouse. All rights reserved.
//

#import "RBLibrary.h"


#import "RBObjectModel.h"

@interface RBLibrary ()
- (BOOL) _createDirectoryAtURL:(NSURL *)aURL error:(NSError **)error;
- (NSPersistentStoreCoordinator *) _createCoordinatorForPersistentStoreAtURL:(NSURL *)aURL error:(NSError **)error;
@end

@implementation RBLibrary

@synthesize URL = _URL;

@synthesize objectModel   = _objectModel;
@synthesize objectContext = _objectContext;

//==================================================================================================
#pragma mark -
#pragma mark Public Methods
//==================================================================================================

+ (id) libraryWithURL:(NSURL *)aURL
{
    return [[[self class] alloc] initWithURL:aURL];
}

- (id) initWithURL:(NSURL *)aURL
{
    self = [super init];
    
    if (self)
    {
        NSPersistentStoreCoordinator *coordinator;
        NSError *error;
        
        coordinator = [self _createCoordinatorForPersistentStoreAtURL:aURL error:&error];
        if (!coordinator)
        {
            [NSApp presentError:error];
            return nil;
        }
        
        self.objectModel   = (RBObjectModel *)coordinator.managedObjectModel;
        self.objectContext = [NSManagedObjectContext new];
        self.objectContext.persistentStoreCoordinator = coordinator;
    }
    
    return self;
}

- (BOOL) save:(NSError **)error
{
    return [self.objectContext save:error];
}


//==================================================================================================
#pragma mark -
#pragma mark Private Methods
//==================================================================================================

- (BOOL) _createDirectoryAtURL:(NSURL *)aURL error:(NSError **)error;
{
    NSDictionary *properties = [aURL resourceValuesForKeys:[NSArray arrayWithObject:NSURLIsDirectoryKey] error:error];
    if (!properties)
    {
        // There's no directory (or file) there. Create one.
        if ([*error code] == NSFileReadNoSuchFileError)
        {
            NSFileManager *fileManager = [NSFileManager defaultManager];
            BOOL result = [fileManager createDirectoryAtURL:aURL
                                withIntermediateDirectories:YES
                                                 attributes:nil
                                                      error:error];
            // Couldn't create the directory. :(
            if (!result)
                return NO;
        }
    }
    // There's a file, but it's not a directory.
    else if (![[properties objectForKey:NSURLIsDirectoryKey] boolValue])
    {
        NSString     *description = [NSString stringWithFormat:@"Expected a directory and fonud a file (%@).", [aURL path]]; 
        NSDictionary *userInfo    = [NSDictionary dictionaryWithObject:description forKey:NSLocalizedDescriptionKey];
        *error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:101 userInfo:userInfo];
        return NO;
    }
    
    return YES;
}

- (NSPersistentStoreCoordinator *) _createCoordinatorForPersistentStoreAtURL:(NSURL *)aURL error:(NSError **)error
{
    // Make sure the directory exists
    NSURL *directory = [aURL URLByDeletingLastPathComponent];
    BOOL   result    = [self _createDirectoryAtURL:directory error:error];
    if (!result)
        return nil;
    
    // Create the coordinator
    RBObjectModel *objectModel;
    NSPersistentStoreCoordinator *coordinator;
    objectModel = [RBObjectModel new];
    coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:objectModel];
    
    // Create the actual store
    NSPersistentStore *store;
    store = [coordinator addPersistentStoreWithType:NSSQLiteStoreType
                                      configuration:nil
                                                URL:aURL
                                            options:nil
                                              error:error];
    if (!store)
        return nil;
    
    return coordinator;
}


@end
