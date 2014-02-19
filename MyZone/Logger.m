
// We need all the log functions visible so we set this to DEBUG
#ifdef COMPILE_TIME_LOG_LEVEL
#undef COMPILE_TIME_LOG_LEVEL
#define COMPILE_TIME_LOG_LEVEL ASL_LEVEL_DEBUG
#endif

#define COMPILE_TIME_LOG_LEVEL ASL_LEVEL_DEBUG

#import "Logger.h"

static void AddStderrOnce()
{
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		asl_add_log_file(NULL, STDERR_FILENO);
	});
}

#define __MAKE_LOG_FUNCTION(LEVEL, NAME) \
void NAME (NSString *format, ...) \
{ \
AddStderrOnce(); \
va_list args; \
va_start(args, format); \
NSString *message = [[NSString alloc] initWithFormat:format arguments:args]; \
asl_log(NULL, NULL, (LEVEL), "%s", [message UTF8String]); \
va_end(args); \
}

__MAKE_LOG_FUNCTION(ASL_LEVEL_EMERG, LogEmergency)
__MAKE_LOG_FUNCTION(ASL_LEVEL_ALERT, LogAlert)
__MAKE_LOG_FUNCTION(ASL_LEVEL_CRIT, LogCritical)
__MAKE_LOG_FUNCTION(ASL_LEVEL_ERR, LogError)
__MAKE_LOG_FUNCTION(ASL_LEVEL_WARNING, LogWarning)
__MAKE_LOG_FUNCTION(ASL_LEVEL_NOTICE, LogNotice)
__MAKE_LOG_FUNCTION(ASL_LEVEL_INFO, LogInfo)
__MAKE_LOG_FUNCTION(ASL_LEVEL_DEBUG, LogDebug)

#undef __MAKE_LOG_FUNCTION