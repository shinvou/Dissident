#import "../Dissident.h"

#import "./ActivatorActions/DissidentActivatorActionToggleForcedBackgrounding.h"
#import "./ActivatorActions/DissidentActivatorActionToggleForcedBackgroundingTemporary.h"

@implementation DissidentActivatorInitializer

+ (id)sharedInstance
{
	static DissidentActivatorInitializer *sharedInstance;

	static dispatch_once_t provider_token;
	dispatch_once(&provider_token, ^{
		sharedInstance = [[self alloc] init];
	});

	return sharedInstance;
}

- (void)initializeActivatorActions
{
	[[objc_getClass("LAActivator") sharedInstance] registerListener:[[DissidentActivatorActionToggleForcedBackgrounding alloc] init] forName:@"com.shinvou.dissident.toggleforcedbackgrounding"];
	[[objc_getClass("LAActivator") sharedInstance] registerListener:[[DissidentActivatorActionToggleForcedBackgroundingTemporary alloc] init] forName:@"com.shinvou.dissident.toggleforcedbackgroundingtmp"];
}

@end
