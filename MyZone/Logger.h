/*
 Logging. Simple wrapper macros/functions around ASL (Apple System
 Log)
 
 We support a compile-time log level through
 COMPILE_TIME_LOG_LEVEL. This will turn the associated log calls
 into NOPs.
 
 The log levels are the constants defined in asl.h:
 
 #define ASL_LEVEL_EMERG   0
 #define ASL_LEVEL_ALERT   1
 #define ASL_LEVEL_CRIT    2
 #define ASL_LEVEL_ERR     3
 #define ASL_LEVEL_WARNING 4
 #define ASL_LEVEL_NOTICE  5
 #define ASL_LEVEL_INFO    6
 #define ASL_LEVEL_DEBUG   7
 
 For a description of when to use each level, see here:
 
 http://developer.apple.com/library/mac/#documentation/MacOSX/Conceptual/BPSystemStartup/Chapters/LoggingErrorsAndWarnings.html#//apple_ref/doc/uid/10000172i-SW8-SW1
 
 Emergency (level 0) - The highest priority, usually reserved for
 catastrophic failures and reboot notices.
 
 Alert (level 1)     - A serious failure in a key system.
 
 Critical (level 2)  - A failure in a key system.
 
 Error (level 3)     - Something has failed.
 
 Warning (level 4)   - Something is amiss and might fail if not
 corrected.
 
 Notice (level 5)    - Things of moderate interest to the user or
 administrator.
 
 Info (level 6)      - The lowest priority that you would normally log, and
 purely informational in nature.
 
 Debug (level 7)     - The lowest priority, and normally not logged except
 for messages from the kernel.
 
 
 Note that by default the iOS syslog/console will only record items up
 to level ASL_LEVEL_NOTICE.
 
 */

/** @todo
 
 We want better multithread support. Default NULL client uses
 locking. Perhaps we can check for [NSThread mainThread] and associate
 an asl client object to that thread. Then we can specify
 ASL_OPT_STDERR and not need an extra call to add stderr.
 
 */

#import <Foundation/Foundation.h>

// By default, in non-debug mode we want to disable any logging
// statements except NOTICE and above.
#ifndef COMPILE_TIME_LOG_LEVEL
#ifdef NDEBUG
#define COMPILE_TIME_LOG_LEVEL ASL_LEVEL_NOTICE
#else
#define COMPILE_TIME_LOG_LEVEL ASL_LEVEL_DEBUG
#endif
#endif

#include <asl.h>

#if COMPILE_TIME_LOG_LEVEL >= ASL_LEVEL_EMERG
void LogEmergency(NSString *format, ...);
#else
#define LogEmergency(...)
#endif

#if COMPILE_TIME_LOG_LEVEL >= ASL_LEVEL_ALERT
void LogAlert(NSString *format, ...);
#else
#define LogAlert(...)
#endif

#if COMPILE_TIME_LOG_LEVEL >= ASL_LEVEL_CRIT
void LogCritical(NSString *format, ...);
#else
#define LogCritical(...)
#endif

#if COMPILE_TIME_LOG_LEVEL >= ASL_LEVEL_ERR
void LogError(NSString *format, ...);
#else
#define LogError(...)
#endif

#if COMPILE_TIME_LOG_LEVEL >= ASL_LEVEL_WARNING
void LogWarning(NSString *format, ...);
#else
#define LogWarning(...)
#endif

#if COMPILE_TIME_LOG_LEVEL >= ASL_LEVEL_NOTICE
void LogNotice(NSString *format, ...);
#else
#define LogNotice(...)
#endif

#if COMPILE_TIME_LOG_LEVEL >= ASL_LEVEL_INFO
void LogInfo(NSString *format, ...);
#else
#define LogInfo(...)
#endif

#if COMPILE_TIME_LOG_LEVEL >= ASL_LEVEL_DEBUG
void LogDebug(NSString *format, ...);
#else
#define LogDebug(...)
#endif
