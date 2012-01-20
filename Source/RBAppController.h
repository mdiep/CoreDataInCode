//
//  RBAppController.h
//  RecipeBook
//
//  Created by Matt Diephouse on 1/18/12.
//  Copyright (c) 2012 Matt Diephouse. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@class RBLibrary;

@interface RBAppController : NSObject <NSApplicationDelegate>

@property (assign) IBOutlet NSWindow *window;

@property (strong, readonly) NSURL *applicationSupportDirectory;
@property (strong) RBLibrary *library;

@end
