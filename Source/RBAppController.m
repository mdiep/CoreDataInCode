//
//  RBAppController.m
//  RecipeBook
//
//  Created by Matt Diephouse on 1/18/12.
//  Copyright (c) 2012 Matt Diephouse. All rights reserved.
//

#import "RBAppController.h"


#import "RBLibrary.h"

@implementation RBAppController

@synthesize window = _window;

@synthesize library = _library;

//==================================================================================================
#pragma mark -
#pragma mark NSApplicationDelegate Methods
//==================================================================================================

- (void) applicationDidFinishLaunching:(NSNotification *)notification
{
    NSURL *libraryURL = [self.applicationSupportDirectory URLByAppendingPathComponent:@"Library.rblibrary"];
    self.library = [RBLibrary libraryWithURL:libraryURL];
}

- (NSApplicationTerminateReply) applicationShouldTerminate:(NSApplication *)sender
{
    NSError *error;
    BOOL result = [self.library save:&error];
    if (!result)
    {
        result = [sender presentError:error];
        if (result)
            return NSTerminateCancel;
        
        NSString *question     = @"Could not save changes while quitting. Quit anyway?";
        NSString *info         = @"Quitting now will lose any changes you have made since the last successful save";
        NSString *quitButton   = @"Quit anyway";
        NSString *cancelButton = @"Cancel";
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setMessageText:question];
        [alert setInformativeText:info];
        [alert addButtonWithTitle:quitButton];
        [alert addButtonWithTitle:cancelButton];
        
        NSInteger answer = [alert runModal];
        
        if (answer == NSAlertAlternateReturn)
            return NSTerminateCancel;
    }
    
    return NSTerminateNow;
}


//==================================================================================================
#pragma mark -
#pragma mark Public Properties
//==================================================================================================

- (NSURL *) applicationSupportDirectory
{
    NSFileManager *fileManager   = [NSFileManager defaultManager];
    NSURL         *libraryURL    = [[fileManager URLsForDirectory:NSLibraryDirectory inDomains:NSUserDomainMask] lastObject];
    NSURL         *appSupportURL = [libraryURL URLByAppendingPathComponent:@"Application Support" isDirectory:YES];
    return [appSupportURL URLByAppendingPathComponent:@"RecipeBook" isDirectory:YES];
}


@end
