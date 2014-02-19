//
//  MyZoneQuery.m
//  MyZone
//
//  Created by Matthew Hillman on 2/10/14.
//  Copyright (c) 2014 Matthew Hillman. All rights reserved.
//

#import "MZQuery.h"
#import "MZEvent.h"
#import "MZWorkout.h"
#import <CommonCrypto/CommonDigest.h>


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

@implementation MZQuery

+ (BOOL)loginUser:(NSString *)user password:(NSString *)password
{
    NSDictionary *result = [MZQuery query:MZRequestTypeLogin withParameters:@{@"email": user, @"password": [MZQuery md5:password]}];
    if (!result) return NO;
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    [standardUserDefaults setObject:result[GUID] forKey:GUID];
    [standardUserDefaults setObject:result[@"coachGUID"] forKey:@"coachGUID"];
    [standardUserDefaults synchronize];

    return YES;
}

+ (BOOL)isLoggedIn
{
    return [[NSUserDefaults standardUserDefaults] valueForKey:GUID] != nil;
}

+ (void)getUserProfileWithCompletionHandler:(void (^)(NSDictionary *results))completion
{
    [MZQuery query:MZRequestTypeProfile withParameters:@{@"guid": [[NSUserDefaults standardUserDefaults] valueForKey:GUID]}
            completionHandler:^(id response) {
                completion((NSDictionary *)response);
            }];
}

+ (void)getUserEventsFrom:(NSDate *)start to:(NSDate *)end completionHandler:(void (^)(NSArray *events))completion
{
    [MZQuery query:MZRequestTypeEvents withParameters:@{@"guid": [[NSUserDefaults standardUserDefaults] valueForKey:GUID],
                                                                               @"startdate": @([start timeIntervalSince1970]),
                                                                               @"enddate": @([end timeIntervalSince1970])}
                            completionHandler:^(id response) {
                                NSArray *jsonEvents = response[@"dates"][@"events"];
                                NSArray *events = @[];
                                
                                for (NSDictionary *jsonEvent in jsonEvents) {
                                    events = [events arrayByAddingObject:[MZEvent eventForJSONEventDictionary:jsonEvent]];
                                }
                                
                                completion(events);
                            }];

}

+ (void)getUserWorkoutsForEvent:(MZEvent *)event completionHandler:(void (^)(NSArray *workouts))completion
{
    [MZQuery getUserWorkoutsFrom:event.start to:event.end completionHandler:completion];
}

+ (void)getUserWorkoutsFrom:(NSDate *)start to:(NSDate *)end completionHandler:(void (^)(NSArray *workouts))completion
{
    [MZQuery query:MZRequestTypeWorkout withParameters:@{@"guid": [[NSUserDefaults standardUserDefaults] valueForKey:GUID],
                                                                                @"start": [[MZQuery shortDateString:start] stringByAppendingString:@" 00:00"],
                                                                                @"end": [[MZQuery shortDateString:end] stringByAppendingString:@" 23:59"]}
                            completionHandler:^(id response) {
                                completion([MZWorkout workoutsForJSONWorkoutDictionary:(NSDictionary *)response[@"chart"]]);
                            }];

}

#pragma mark Private Methods

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
    static NSString *query = @"?%@";
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setHTTPMethod:@"GET"];
    
    NSString *get = [NSString stringWithFormat:@"requestType=%d", type];
    
    for (NSString *key in parameters) {
        get = [get stringByAppendingString:[NSString stringWithFormat:@"&%@=%@", key, parameters[key]]];
    }
    LogDebug(@"query string: %@", get);
    NSURL *reqUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", url, [NSString stringWithFormat:query, [get stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]]];
    request.URL = reqUrl;
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration ephemeralSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];
    NSURLSessionDownloadTask *task = [session downloadTaskWithRequest:request completionHandler:^(NSURL *localFile, NSURLResponse *response, NSError *error) {
        if (!error) {
            if ([request.URL isEqual:reqUrl]) {
                NSString *jsonResult = [[NSString alloc] initWithData:[NSData dataWithContentsOfURL:localFile] encoding:NSUTF8StringEncoding];
                
                NSData *jsonData = [jsonResult dataUsingEncoding:NSUTF8StringEncoding];
                NSError *e;
                id res = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&e];
                
                dispatch_async(dispatch_get_main_queue(), ^{ completion(res); });
            }
        } else {
            LogError(@"Error retrieving query from MyZone:\n%@", error);
        }
    }];
    
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
    
    NSString *get = [NSString stringWithFormat:@"requestType=%d", type];
    
    for (NSString *key in parameters) {
        get = [get stringByAppendingString:[NSString stringWithFormat:@"&%@=%@", key, parameters[key]]];
    }
    //    get = [NSString stringWithFormat:query, [get substringToIndex:get.length-(get.length>0)]];
    LogDebug(@"query string: %@", get);
    NSURL *reqUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", url, [NSString stringWithFormat:query, [get stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]]];
    request.URL = reqUrl;
    
    NSHTTPURLResponse *response = nil;
    NSError *error = [[NSError alloc] init];
    NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    NSString *jsonResult = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];

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
    CC_MD5(cStr, strlen(cStr), digest); // This is the md5 call
    
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
        NSMutableDictionary *res = [@{} mutableCopy];
        
        for (id key in (NSDictionary *)obj) {
            res[key] = [MZQuery convertOjbect:[(NSDictionary *)obj objectForKey:key]];
        }
        
        ret = res;
    } else if ([obj isKindOfClass:[NSArray class]]) {
        NSMutableArray *res = [@[] mutableCopy];
        
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
@end
