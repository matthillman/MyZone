//
//  AppDelegate+MDC.h
//  MyZone
//
//  Created by Matthew Hillman on 4/4/14.
//  Copyright (c) 2014 Matthew Hillman. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate (MDC)
- (UIManagedDocument *)openDocumentNamed:(NSString *)name completion:(void (^)(BOOL))completion;
@end
