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
- (BOOL) _migratePersistentStoreAtURL:(NSURL *)aURL
                            fromModel:(RBObjectModel *)sourceModel
                              toModel:(RBObjectModel *)destinationModel
                                error:(NSError **)error;
- (BOOL) _migratePersistentStoreAtURL:(NSURL *)aURL error:(NSError **)error;
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

- (BOOL) _migratePersistentStoreAtURL:(NSURL *)aURL
                            fromModel:(RBObjectModel *)sourceModel
                              toModel:(RBObjectModel *)destinationModel
                                error:(NSError **)error
{
    BOOL result;
    NSURL *destURL   = [aURL URLByAppendingPathExtension:@"tmp"];
    NSURL *resultURL = nil;
    
    // Find a mapping model.
    NSMappingModel *mappingModel = destinationModel.mappingModel;
    if (!mappingModel)
    {
        mappingModel = [NSMappingModel inferredMappingModelForSourceModel:sourceModel
                                                         destinationModel:destinationModel
                                                                    error:error];
    }
    if (!mappingModel)
        return NO;
    
    // Perform the migration
    NSMigrationManager *manager = [[NSMigrationManager alloc] initWithSourceModel:sourceModel
                                                                 destinationModel:destinationModel];
    result = [manager migrateStoreFromURL:aURL
                                     type:NSSQLiteStoreType
                                  options:nil
                         withMappingModel:mappingModel
                         toDestinationURL:destURL
                          destinationType:NSSQLiteStoreType
                       destinationOptions:nil
                                    error:error];
    if (!result)
        return NO;
    
    // Replace the original store with the migrated one
    NSFileManager *fileManager = [NSFileManager defaultManager];
    result = [fileManager replaceItemAtURL:aURL
                             withItemAtURL:destURL
                            backupItemName:@"Backup.rblibrary"
                                   options:0
                          resultingItemURL:&resultURL
                                     error:error];
    if (!result)
        return NO;
    
    return YES;
}

- (BOOL) _migratePersistentStoreAtURL:(NSURL *)aURL error:(NSError **)error
{
    NSArray      *allVersions = [RBObjectModel allVersions];
    NSDictionary *metadata    = [NSPersistentStoreCoordinator metadataForPersistentStoreOfType:NSSQLiteStoreType
                                                                                           URL:aURL
                                                                                         error:error];
    if (!metadata)
        return NO;
    
    // Find the most recent version that's compatible
    RBObjectModel *compatibleVersion = nil;
    for (RBObjectModel *version in [allVersions reverseObjectEnumerator])
    {
        BOOL isCompatible = [version isConfiguration:nil compatibleWithStoreMetadata:metadata];
        if (isCompatible)
        {
            compatibleVersion = version;
            break;
        }
    }
    
    if (!compatibleVersion)
    {
        NSString     *description = [NSString stringWithFormat:@"Could not open library at URL: '%@'.", [aURL path]]; 
        NSDictionary *userInfo    = [NSDictionary dictionaryWithObject:description forKey:NSLocalizedDescriptionKey];
        *error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:101 userInfo:userInfo];
        return NO;
    }
    
    // Migrate the store one version at a time
    NSInteger      compatibleIndex  = [allVersions indexOfObjectIdenticalTo:compatibleVersion];
    RBObjectModel *sourceModel      = compatibleVersion;
    NSRange        newerModelsRange = NSMakeRange(compatibleIndex+1, allVersions.count-(compatibleIndex+1));
    for (RBObjectModel *destModel in [allVersions subarrayWithRange:newerModelsRange])
    {
        BOOL result = [self _migratePersistentStoreAtURL:aURL
                                               fromModel:sourceModel
                                                 toModel:destModel
                                                   error:error];
        if (!result)
            return NO;
        
        sourceModel = destModel;
    }
    
    return YES;
}

- (NSPersistentStoreCoordinator *) _createCoordinatorForPersistentStoreAtURL:(NSURL *)aURL error:(NSError **)error
{
    BOOL result;
    
    // Make sure the directory exists
    NSURL *directory = [aURL URLByDeletingLastPathComponent];
    result = [self _createDirectoryAtURL:directory error:error];
    if (!result)
        return nil;
    
    // Migrate the store if needed
    result = [self _migratePersistentStoreAtURL:aURL error:error];
    if (!result)
        return nil;
    
    // Create the coordinator
    RBObjectModel *objectModel;
    NSPersistentStoreCoordinator *coordinator;
    objectModel = [RBObjectModel currentVersion];
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
