//
//  AppDelegate+MDC.m
//  MyZone
//
//  Created by Matthew Hillman on 4/4/14.
//  Copyright (c) 2014 Matthew Hillman. All rights reserved.
//

#import "AppDelegate+MDC.h"

@implementation AppDelegate (MDC)

- (UIManagedDocument *)openDocumentNamed:(NSString *)name completion:(void (^)(BOOL success))completion
{
    NSURL *url = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:name];
    UIManagedDocument *document = [[UIManagedDocument alloc] initWithFileURL:url];
    if ([[NSFileManager defaultManager] fileExistsAtPath:[url path]]) {
        [document openWithCompletionHandler:completion];
    } else {
        [document saveToURL:url forSaveOperation:UIDocumentSaveForCreating
               completionHandler:completion];
    }
    return document;
}

- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

@end
