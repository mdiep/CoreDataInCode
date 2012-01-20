//
//  RBLibrary.h
//  RecipeBook
//
//  Created by Matt Diephouse on 1/19/12.
//  Copyright (c) 2012 Matt Diephouse. All rights reserved.
//

#import <Foundation/Foundation.h>


@class RBObjectModel;

@interface RBLibrary : NSObject

@property (strong) NSURL *URL;

@property (strong) RBObjectModel          *objectModel;
@property (strong) NSManagedObjectContext *objectContext;

+ (id) libraryWithURL:(NSURL *)aURL;
- (id) initWithURL:(NSURL *)aURL;

- (BOOL) save:(NSError **)error;

@end
