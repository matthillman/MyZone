//
//  MyZoneQuery.m
//  MyZone
//
//  Created by Matthew Hillman on 2/10/14.
//  Copyright (c) 2014 Matthew Hillman. All rights reserved.
//

#import "MZQuery.h"
#import "MZEvent.h"
#import "Workout+MZ.h"
#import <CommonCrypto/CommonDigest.h>
#import "SSKeychain.h"

enum {
	MZRequestTypeLogin   = 1,
	MZRequestTypeStats,
	MZRequestTypeProfile,
	MZRequestTypeGPoints,
	MZRequestTypeHealth,
	MZRequestTypeChallenges,
	MZRequestTypeEvents,
	MZRequestTypeSummary,
	MZRequestTypeNotes,
	MZRequestTypeWorkout,
	MZRequestTypeLatestMove,
	MZRequestTypeFood,
	MZRequestTypeFoodNotes,
	MZRequestTypeBodyImages
};
typedef NSUInteger MZRequestType;

#define GUID @"GUID"
#define USER @"USER"
#define MYZONE @"mz"

@interface MZQuery () <NSURLSessionDownloadDelegate>
@property (strong, nonatomic) NSURLSession *backgroundSession;
@property (strong, nonatomic) NSManagedObjectContext *context;
@end

@implementation MZQuery

+ (id)sharedQuery
{
    static MZQuery *sharedQuery = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedQuery = [[self alloc] init];
    });
    return sharedQuery;
}

#pragma mark Login

+ (BOOL)loginUser:(NSString *)user password:(NSString *)password
{
    NSDictionary *result = [MZQuery query:MZRequestTypeLogin withParameters:@{@"email": user, @"password": [MZQuery md5:password]}];
    if (!result) return NO;
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    [standardUserDefaults setObject:result[GUID] forKey:GUID];
    [standardUserDefaults setObject:result[@"coachGUID"] forKey:@"coachGUID"];
    [standardUserDefaults setObject:user forKey:USER];
    [standardUserDefaults synchronize];
    
    [SSKeychain setPassword:password forService:MYZONE account:user];
    
    return YES;
}

+ (BOOL)isLoggedIn
{
    return [[NSUserDefaults standardUserDefaults] valueForKey:GUID] != nil;
}

+ (NSString *)loggedInId
{
    return [[NSUserDefaults standardUserDefaults] valueForKey:GUID];
}

#pragma mark User Profile

+ (void)getUserProfileWithCompletionHandler:(void (^)(NSDictionary *results))completion
{
    [MZQuery query:MZRequestTypeProfile withParameters:@{@"guid": [[NSUserDefaults standardUserDefaults] valueForKey:GUID]}
            completionHandler:^(id response) {
                completion((NSDictionary *)response);
            }];
}

#pragma mark Queries with Completion Blocks

+ (void)doWorkoutQueryInContext:(NSManagedObjectContext *)context all:(BOOL)all completion:(void (^)(BOOL newData))completion
{
    NSDate *s = nil;
    NSFetchRequest *dateRequest = [[NSFetchRequest alloc] initWithEntityName:@"Workout"];
    dateRequest.resultType = NSDictionaryResultType;
    NSString *function = all ? @"min:" : @"max:";
    NSExpressionDescription *expressionDescription = [[NSExpressionDescription alloc] init];
    expressionDescription.name = @"startDate";
    expressionDescription.expression = [NSExpression expressionForFunction:function arguments:@[[NSExpression expressionForKeyPath:@"start"]]];
    expressionDescription.expressionResultType = NSDateAttributeType;
    dateRequest.propertiesToFetch = @[expressionDescription];
    
    NSError *error = nil;
    NSArray *fetchResult = [context executeFetchRequest:dateRequest error:&error];
    if (fetchResult == nil) {
        LogDebug(@"%@", error.debugDescription);
    } else {
        s = [[fetchResult firstObject] valueForKey:@"startDate"];
    }
    if (!s) {
        NSDateComponents *comp = [[NSDateComponents alloc] init];
        comp.month = -4;
        s = [[NSCalendar currentCalendar] dateByAddingComponents:comp toDate:[NSDate date] options:0];
        LogDebug(@"Using date {%@} becuase there were no results", s);
    } else {
        NSDateComponents *comp = [[NSDateComponents alloc] init];
        comp.day = -1;
        s = [[NSCalendar currentCalendar] dateByAddingComponents:comp toDate:s options:0];
        LogDebug(@"Fetched date {%@} using {%@}", s, function);
    }
    
    [MZQuery getUserEventsFrom:s to:[NSDate date] completionHandler:^(NSArray *events) {
        if (![events count]) {
            dispatch_async(dispatch_get_main_queue(), ^{ completion(NO); });
        } else {
            NSMutableArray *fetchedEvents = [NSMutableArray arrayWithCapacity:[events count]];
            for (MZEvent *event in events) {
                [MZQuery getUserWorkoutsForEvent:event inContext:context completionHandler:^(NSArray *workouts) {
                    for (Workout *w in workouts) {
                        w.maxHeartRate = event.maximumHeartRate;
                    }
                    [fetchedEvents addObject:event];
                    if ([fetchedEvents count] == [events count]) {
                        dispatch_async(dispatch_get_main_queue(), ^{ completion(YES); });
                    }
                }];
            }
        }
    }];
}

+ (void)getUserEventsFrom:(NSDate *)start to:(NSDate *)end completionHandler:(void (^)(NSArray *events))completion
{
    [MZQuery query:MZRequestTypeEvents
    withParameters:@{@"guid": [[NSUserDefaults standardUserDefaults] valueForKey:GUID],
                     @"startdate": @([start timeIntervalSince1970]),
                     @"enddate": @([end timeIntervalSince1970])}
 completionHandler:^(id response) {
     NSArray *events = @[];
     if ([response[@"dates"][@"events"] isKindOfClass:[NSArray class]]) {
         NSArray *jsonEvents = response[@"dates"][@"events"];
         
         for (NSDictionary *jsonEvent in jsonEvents) {
             events = [events arrayByAddingObject:[MZEvent eventForJSONEventDictionary:jsonEvent]];
         }
     }
     completion(events);
 }];

}

+ (void)getUserWorkoutsForEvent:(MZEvent *)event inContext:(NSManagedObjectContext *)context completionHandler:(void (^)(NSArray *workouts))completion
{
    [MZQuery getUserWorkoutsFrom:event.start to:event.end inContext:context completionHandler:completion];
}

+ (void)getUserWorkoutsFrom:(NSDate *)start to:(NSDate *)end inContext:(NSManagedObjectContext *)context completionHandler:(void (^)(NSArray *workouts))completion
{
    [MZQuery query:MZRequestTypeWorkout
    withParameters:@{@"guid": [[NSUserDefaults standardUserDefaults] valueForKey:GUID],
                     @"start": [[MZQuery shortDateString:start] stringByAppendingString:@" 00:00"],
                     @"end": [[MZQuery shortDateString:end] stringByAppendingString:@" 23:59"]}
 completionHandler:^(id response) {
     [context performBlock:^{
         NSArray *res = [Workout workoutsForJSONWorkoutDictionary:(NSDictionary *)response[@"chart"] inContext:context];
         [context save:NULL];
         dispatch_async(dispatch_get_main_queue(), ^{ completion(res); });
     }];
 }];
}

#pragma mark Queries with Delegate (background)

- (void)doWorkoutQueryInContext:(NSManagedObjectContext *)context all:(BOOL)all
{
    [self.backgroundSession getTasksWithCompletionHandler:^(NSArray *dataTasks, NSArray *uploadTasks, NSArray *downloadTasks) {
        // let's see if we're already working on a fetch ...
        if (![downloadTasks count]) {
            self.context = context;
//            [self query:MZRequestTypeEvents
//         withParameters:@{@"guid": [[NSUserDefaults standardUserDefaults] valueForKey:GUID],
//                          @"startdate": @([[MZQuery getStartDateInContext:context all:all] timeIntervalSince1970]),
//                          @"enddate": @([[NSDate date] timeIntervalSince1970])}];
            [self getUserWorkoutsFrom:[MZQuery getStartDateInContext:self.context all:all] to:[NSDate date]];
        } else {
            // ... we are working on a fetch (let's make sure it (they) is (are) running while we're here)
            for (NSURLSessionDownloadTask *task in downloadTasks) [task resume];
        }
    }];
}

- (void)getUserWorkoutsForEvent:(MZEvent *)event
{
    [self query:MZRequestTypeWorkout
    withParameters:@{@"guid": [[NSUserDefaults standardUserDefaults] valueForKey:GUID],
                     @"start": [[MZQuery shortDateString:event.start] stringByAppendingString:@" 00:00"],
                     @"end": [[MZQuery shortDateString:event.end] stringByAppendingString:@" 23:59"]}];
}

- (void)getUserWorkoutsFrom:(NSDate *)start to:(NSDate *)end
{
    [self query:MZRequestTypeWorkout
 withParameters:@{@"guid": [[NSUserDefaults standardUserDefaults] valueForKey:GUID],
                  @"start": [[MZQuery shortDateString:start] stringByAppendingString:@" 00:00"],
                  @"end": [[MZQuery shortDateString:end] stringByAppendingString:@" 23:59"]}];
}

#pragma mark Util Methods

+ (MZZoneKey)zoneForAverageEffort:(NSString *)averageEffort
{
    NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
    f.numberStyle = NSNumberFormatterPercentStyle;
    NSNumber *z = [f numberFromString:averageEffort];
    NSUInteger result = floor([z doubleValue] * 10) - 4;
    return MAX(result, 0);
}

#pragma mark Private Methods

+ (NSDate *)getStartDateInContext:(NSManagedObjectContext *)context all:(BOOL)all
{
    NSDate *s = nil;
    NSFetchRequest *dateRequest = [[NSFetchRequest alloc] initWithEntityName:@"Workout"];
    dateRequest.resultType = NSDictionaryResultType;
    NSString *function = all ? @"min:" : @"max:";
    NSExpressionDescription *expressionDescription = [[NSExpressionDescription alloc] init];
    expressionDescription.name = @"startDate";
    expressionDescription.expression = [NSExpression expressionForFunction:function arguments:@[[NSExpression expressionForKeyPath:@"start"]]];
    expressionDescription.expressionResultType = NSDateAttributeType;
    dateRequest.propertiesToFetch = @[expressionDescription];
    
    NSError *error = nil;
    NSArray *fetchResult = [context executeFetchRequest:dateRequest error:&error];
    if (fetchResult == nil) {
        LogDebug(@"%@", error.debugDescription);
    } else {
        s = [[fetchResult firstObject] valueForKey:@"startDate"];
    }
    if (!s) {
        NSDateComponents *comp = [[NSDateComponents alloc] init];
        comp.month = -4;
        s = [[NSCalendar currentCalendar] dateByAddingComponents:comp toDate:[NSDate date] options:0];
        LogDebug(@"Using date {%@} becuase there were no results", s);
    } else {
        NSDateComponents *comp = [[NSDateComponents alloc] init];
        comp.day = -1;
        s = [[NSCalendar currentCalendar] dateByAddingComponents:comp toDate:s options:0];
        LogDebug(@"Fetched date {%@} using {%@}", s, function);
    }
    
    return s;
}

- (void)query:(MZRequestType)type withParameters:(NSDictionary *)parameters
{
    static NSString *url = @"http://myzonemoves.com/myzone/mobile/";
    
    NSString *get = [NSString stringWithFormat:@"requestType=%lu", (unsigned long)type];
    for (NSString *key in parameters) {
        get = [get stringByAppendingString:[NSString stringWithFormat:@"&%@=%@", key, parameters[key]]];
    }
    
    static NSString *query = @"?%@";
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    NSString *formatted = [NSString stringWithFormat:query, [get stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    [request setHTTPMethod:@"GET"];
    
    NSURL *reqUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", url, formatted]];
    request.URL = reqUrl;
    
    NSURLSessionDownloadTask *task = [self.backgroundSession downloadTaskWithRequest:request];
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    [task resume];
}

- (NSURLSession *)backgroundSession
{
    if (!_backgroundSession) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:MZ_SESSION];
            _backgroundSession = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:nil];
        });
    }
    return _backgroundSession;
}

+ (id)processResult:(NSURL *)localFile
{
    NSString *jsonResult = [[NSString alloc] initWithData:[NSData dataWithContentsOfURL:localFile] encoding:NSUTF8StringEncoding];
    
    NSData *jsonData = [jsonResult dataUsingEncoding:NSUTF8StringEncoding];
    NSError *e;
    id res = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&e];
    if (e != nil) {
        if (e.code == 3840) {
            res = jsonResult;
        } else {
            LogError(@"Error decoding json\n%@\nwith error\n%@", jsonResult, e);
        }
    }
    return [MZQuery convertOjbect:res];
}

/**
 * Queries the MyZone Site
 *
 * @param type Request type. See MZRequestType for possible types
 * @param parameters Dictionary of parameters. Query will be built such that key=value in the request. Caller must ensure parameters are valid
 * @return NSDictionary or NSArray dpeending on what is returned by the query, nil if there is no result or if it is invalid.
 */
+ (void)query:(MZRequestType)type withParameters:(NSDictionary *)parameters completionHandler:(void (^)(id response))completion
{
    static NSString *url = @"http://myzonemoves.com/myzone/mobile/";

    NSString *get = [NSString stringWithFormat:@"requestType=%lu", (unsigned long)type];
    for (NSString *key in parameters) {
        get = [get stringByAppendingString:[NSString stringWithFormat:@"&%@=%@", key, parameters[key]]];
    }

    [MZQuery queryUrl:url withQueryString:get completion:completion];
}

+ (void)queryUrl:(NSString *)url withQueryString:(NSString *)queryString completion:(void (^)(id response))completion
{
    static NSString *query = @"?%@";
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    NSString *formatted = queryString ? [NSString stringWithFormat:query, [queryString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]] : @"";
    [request setHTTPMethod:@"GET"];
   
    NSURL *reqUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", url, formatted]];
    request.URL = reqUrl;
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration ephemeralSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];
    NSURLSessionDownloadTask *task = [session downloadTaskWithRequest:request completionHandler:^(NSURL *localFile, NSURLResponse *response, NSError *error) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        if (!error) {
            if ([request.URL isEqual:reqUrl]) {
                NSString *jsonResult = [[NSString alloc] initWithData:[NSData dataWithContentsOfURL:localFile] encoding:NSUTF8StringEncoding];
                
                NSData *jsonData = [jsonResult dataUsingEncoding:NSUTF8StringEncoding];
                NSError *e;
                id res = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&e];
                if (e != nil) {
                    if (e.code == 3840) {
                        res = jsonResult;
                    } else {
                        LogError(@"Error decoding json\n%@\nwith error\n%@", jsonResult, e);
                    }
                }
                res = [MZQuery convertOjbect:res];
//                dispatch_async(dispatch_get_main_queue(), ^{
                    completion(res);
//                });
            }
        } else {
            LogError(@"Error retrieving query from MyZone:\n%@", error);
        }
    }];
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    [task resume];
}

+ (void)updateWorkout:(NSNumber *)hrhIndex activity:(NSString *)activityId completionHandler:(void (^)(id response))completion
{
    static NSString *url = @"http://myzonemoves.com/myzone/dashboard/sections/saveactivity.php";
    static NSString *query = @"?actIndex=%@&hrhIndex=%@";
    
    [MZQuery loginToFullSiteWithCompletion:^(NSURLSession *session, NSDictionary *cookies) {
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
        [request setHTTPMethod:@"GET"];
        NSString *formatted = [[NSString stringWithFormat:query, activityId, hrhIndex] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSURL *reqUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", url, formatted]];
        request.URL = reqUrl;
        
        [request setAllHTTPHeaderFields:cookies];
        
        NSURLSessionDownloadTask *task = [session downloadTaskWithRequest:request completionHandler:^(NSURL *localFile, NSURLResponse *response, NSError *error) {
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
            if (!error) {
                if ([request.URL isEqual:reqUrl]) {
                    NSString *jsonResult = [[NSString alloc] initWithData:[NSData dataWithContentsOfURL:localFile] encoding:NSUTF8StringEncoding];
                    
                    NSData *jsonData = [jsonResult dataUsingEncoding:NSUTF8StringEncoding];
                    NSError *e;
                    id res = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&e];
                    if (e != nil) {
                        if (e.code == 3840) {
                            res = jsonResult;
                        } else {
                            LogError(@"Error decoding json\n%@\nwith error\n%@", jsonResult, e);
                        }
                    }
                    res = [MZQuery convertOjbect:res];
                    dispatch_async(dispatch_get_main_queue(), ^{ completion(res); });
                }
            } else {
                LogError(@"Error retrieving query from MyZone:\n%@", error);
            }
        }];
        
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        [task resume];
    }];
}

+ (void)loginToFullSiteWithCompletion:(void (^)(NSURLSession *session, NSDictionary *cookies))completion
{
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];
    
    NSMutableURLRequest *request2 = [[NSMutableURLRequest alloc] init];
    [request2 setHTTPMethod:@"GET"];
    
    NSURL *reqUrl2 = [NSURL URLWithString:@"http://myzonemoves.com/index.php"];
    request2.URL = reqUrl2;
    NSURLSessionDownloadTask *task = [session downloadTaskWithRequest:request2 completionHandler:^(NSURL *localFile, NSURLResponse *response, NSError *error) {
        if (!error) {
            if ([request2.URL isEqual:reqUrl2]) {
                NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
                NSString *username = [[NSUserDefaults standardUserDefaults] valueForKey:USER];
                NSString *password = [SSKeychain passwordForService:MYZONE account:username];
                NSString *formatted = [[NSString stringWithFormat:@"email=%@&password=%@&login=Log+In", username, password]
                                       stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                [request setHTTPMethod:@"POST"];
                
                NSURL *reqUrl = [NSURL URLWithString:@"http://myzonemoves.com/myzone/login/"];
                request.URL = reqUrl;
                
                NSData *postData = [formatted dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
                NSDictionary *cookieHeaders = [NSHTTPCookie requestHeaderFieldsWithCookies:[[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:reqUrl]];
                [request setAllHTTPHeaderFields:cookieHeaders];
                
                NSURLSessionUploadTask *utask = [session uploadTaskWithRequest:request fromData:postData completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
                    if (!error) {
                        if ([request.URL isEqual:reqUrl]) {
//                            dispatch_async(dispatch_get_main_queue(), ^{
                                completion(session, cookieHeaders);
//                            });
                        }
                    } else {
                        LogError(@"Error retrieving query from MyZone:\n%@", error);
                    }
                }];
                
                [utask resume];
            }
        } else {
            LogError(@"Error retrieving query from MyZone:\n%@", error);
        }
    }];
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    [task resume];
}

/**
 * Queries the MyZone Site In a Blocking Manner. Prefer the query with the completion block.
 *
 * @param type Request type. See MZRequestType for possible types
 * @param parameters Dictionary of parameters. Query will be built such that key=value in the request. Caller must ensure parameters are valid
 * @return NSDictionary or NSArray dpeending on what is returned by the query, nil if there is no result or if it is invalid.
 */
+ (id)query:(MZRequestType)type withParameters:(NSDictionary *)parameters
{
    static NSString *url = @"http://myzonemoves.com/myzone/mobile/";
    static NSString *query = @"?%@";
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setHTTPMethod:@"GET"];
    
    NSString *get = [NSString stringWithFormat:@"requestType=%lu", (unsigned long)type];
    
    for (NSString *key in parameters) {
        get = [get stringByAppendingString:[NSString stringWithFormat:@"&%@=%@", key, parameters[key]]];
    }
    //    get = [NSString stringWithFormat:query, [get substringToIndex:get.length-(get.length>0)]];
    LogDebug(@"query string: %@", get);
    NSURL *reqUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", url, [NSString stringWithFormat:query, [get stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]]];
    request.URL = reqUrl;
    
    NSHTTPURLResponse *response = nil;
    NSError *error = [[NSError alloc] init];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    NSString *jsonResult = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    
    if ([response statusCode] >= 200 && [response statusCode] < 300) {
        NSData *jsonData = [jsonResult dataUsingEncoding:NSUTF8StringEncoding];
        NSError *e;
        id res = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&e];

        return [MZQuery convertOjbect:res];
    }
    
    return nil;
}

/**
 * Returns the MD5 hash of the string using CC_MD5
 *
 * @param input NSString * to be hashed
 * @return The MD5 hash as a NSString *
 */
+ (NSString *)md5:(NSString *)input
{
    const char *cStr = [input UTF8String];
    unsigned char digest[16];
    CC_MD5(cStr, (int)strlen(cStr), digest); // This is the md5 call
    
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x", digest[i]];
    
    return  output;
    
}

/**
 * Returns the given date in the format: yyy-MM-dd
 *
 * @param date NSDate * instace to be formatted
 * @return The formatted date as a NSString
 */
+ (NSString *)shortDateString:(NSDate *)date
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    
    return [formatter stringFromDate:date];
}

+ (id)convertOjbect:(NSObject *)obj
{
    id ret;
    if ([obj isKindOfClass:[NSDictionary class]]) {
        NSMutableDictionary *res = [NSMutableDictionary dictionary];
        
        for (id key in (NSDictionary *)obj) {
            res[key] = [MZQuery convertOjbect:[(NSDictionary *)obj objectForKey:key]];
        }
        
        ret = res;
    } else if ([obj isKindOfClass:[NSArray class]]) {
        NSMutableArray *res = [NSMutableArray array];
        
        for (NSObject *item in (NSArray *)obj) {
            [res addObject:[MZQuery convertOjbect:item]];
        }
        
        ret = res;
    } else if ([obj isKindOfClass:[NSNumber class]]) {
        ret = obj;
    } else if ([obj isKindOfClass:[NSString class]]) {
        NSNumberFormatter * f = [[NSNumberFormatter alloc] init];
        [f setNumberStyle:NSNumberFormatterDecimalStyle];
        NSNumber *test = [f numberFromString:(NSString *)obj];
        if (test) {
            ret = test;
        } else {
            ret = obj;
        }
    } else {
        ret = obj;
    }
    
    return ret;
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location
{
    NSDictionary *response = [MZQuery processResult:location];
    if ([response[@"dates"][@"events"] isKindOfClass:[NSArray class]]) {
        NSArray *jsonEvents = response[@"dates"][@"events"];
        for (NSDictionary *jsonEvent in jsonEvents) {
            MZEvent *event = [MZEvent eventForJSONEventDictionary:jsonEvent];
            [self getUserWorkoutsForEvent:event];
        }
        LogDebug(@"Got %d events", [jsonEvents count]);
    } else if ([response[@"chart"] isKindOfClass:[NSDictionary class]]) {
        /*NSArray *workouts = */[Workout workoutsForJSONWorkoutDictionary:response[@"chart"] inContext:self.context];
//        for (Workout *w in workouts) {
//            w.maxHeartRate = self.event.maximumHeartRate;
//        }
        [self.context save:NULL];
        LogDebug(@"Updated workouts");
    }
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didResumeAtOffset:(int64_t)fileOffset expectedTotalBytes:(int64_t)expectedTotalBytes
{
    
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite
{
    
}

@end
