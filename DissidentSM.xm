#import "Dissident.h"

static int isPurchased = 0;

@implementation DissidentSM

+ (id)sharedInstance
{
	static DissidentSM *sharedInstance;

	static dispatch_once_t provider_token;
	dispatch_once(&provider_token, ^{
		sharedInstance = [[self alloc] init];
	});

	return sharedInstance;
}

- (BOOL)isActivatorSupported
{
	dlopen("/usr/lib/libactivator.dylib", RTLD_LAZY);

	Class activatorClass = objc_getClass("LAActivator");

	if (activatorClass) return YES;

	return NO;
}

- (BOOL)isStatusbarSupported
{
	dlopen("/Library/MobileSubstrate/DynamicLibraries/libstatusbar.dylib", RTLD_LAZY);

	Class statusbarClass = objc_getClass("LSStatusBarItem");

	if (statusbarClass) return YES;

	return NO;
}

- (BOOL)globalHasPreventTerminationSettings
{
	NSMutableDictionary *settings = [[NSMutableDictionary alloc] init];
	[settings addEntriesFromDictionary:[NSDictionary dictionaryWithContentsOfFile:settingsPath]];

	if ([[settings objectForKey:@"globalPreventTermination"] containsObject:@(1)]) {
		return YES;
	} else {
		return NO;
	}
}

- (BOOL)identifierHasPreventTerminationSettings:(NSString *)identifier
{
	NSMutableDictionary *settings = [[NSMutableDictionary alloc] init];
	[settings addEntriesFromDictionary:[NSDictionary dictionaryWithContentsOfFile:settingsPath]];

	if ([[settings objectForKey:@"identifierPreventTermination"] containsObject:identifier]) {
		return YES;
	} else {
		return NO;
	}
}

- (int)globalBackgroundMode
{
	NSMutableDictionary *settings = [[NSMutableDictionary alloc] init];
	[settings addEntriesFromDictionary:[NSDictionary dictionaryWithContentsOfFile:settingsPath]];

	if ([[settings objectForKey:@"globalBackgroundMode"] containsObject:@(0)]) {
		return 0;
	} else if ([[settings objectForKey:@"globalBackgroundMode"] containsObject:@(1)]) {
		return 1;
	} else if ([[settings objectForKey:@"globalBackgroundMode"] containsObject:@(2)]) {
		return 2;
	} else if ([[settings objectForKey:@"globalBackgroundMode"] containsObject:@(3)]) {
		return 3;
	} else if ([[settings objectForKey:@"globalBackgroundMode"] containsObject:@(4)]) {
		return 4;
	} else {
		return 5;
	}
}

- (int)backgroundModeForIdentifier:(NSString *)identifier
{
	NSMutableDictionary *settings = [[NSMutableDictionary alloc] init];
	[settings addEntriesFromDictionary:[NSDictionary dictionaryWithContentsOfFile:settingsPath]];

	if ([[settings objectForKey:@"backgroundModeOff"] containsObject:identifier]) {
		return 0;
	} else if ([[settings objectForKey:@"backgroundModeFastFreeze"] containsObject:identifier]) {
		return 1;
	} else if ([[settings objectForKey:@"backgroundModeNative"] containsObject:identifier]) {
		return 2;
	} else if ([[settings objectForKey:@"backgroundModeUnlimitedNative"] containsObject:identifier]) {
		return 3;
	} else if ([[settings objectForKey:@"backgroundModeForeground"] containsObject:identifier]) {
		return 4;
	} else {
		return 5;
	}
}

- (BOOL)identifierHasAutomaticLaunchSettings:(NSString *)identifier
{
	NSMutableDictionary *settings = [[NSMutableDictionary alloc] init];
	[settings addEntriesFromDictionary:[NSDictionary dictionaryWithContentsOfFile:settingsPath]];

	if ([[settings objectForKey:@"shouldAutomaticallyLaunch"] containsObject:identifier]) {
		return YES;
	} else {
		return NO;
	}
}

- (BOOL)identifierHasAutomaticRelaunchSettings:(NSString *)identifier
{
	NSMutableDictionary *settings = [[NSMutableDictionary alloc] init];
	[settings addEntriesFromDictionary:[NSDictionary dictionaryWithContentsOfFile:settingsPath]];

	if ([[settings objectForKey:@"shouldAutomaticallyRelaunch"] containsObject:identifier]) {
		return YES;
	} else {
		return NO;
	}
}

- (BOOL)iconBadgeIsEnabled
{
	NSMutableDictionary *settings = [[NSMutableDictionary alloc] init];
	[settings addEntriesFromDictionary:[NSDictionary dictionaryWithContentsOfFile:settingsPath]];

	if ([[settings objectForKey:@"iconBadge"] containsObject:@"enabled"]) {
		return YES;
	} else {
		return NO;
	}
}

- (BOOL)iconBadgeIsEnabledForBackgroundMode:(NSString *)backgroundMode
{
	NSMutableDictionary *settings = [[NSMutableDictionary alloc] init];
	[settings addEntriesFromDictionary:[NSDictionary dictionaryWithContentsOfFile:settingsPath]];

	if ([[settings objectForKey:@"iconBadge"] containsObject:backgroundMode]) {
		return YES;
	} else {
		return NO;
	}
}

- (BOOL)statusbarIconIsEnabled
{
	NSMutableDictionary *settings = [[NSMutableDictionary alloc] init];
	[settings addEntriesFromDictionary:[NSDictionary dictionaryWithContentsOfFile:settingsPath]];

	if ([[settings objectForKey:@"statusbarIcon"] containsObject:@"enabled"]) {
		return YES;
	} else {
		return NO;
	}
}

- (BOOL)statusbarIconIsEnabledForBackgroundMode:(NSString *)backgroundMode
{
	NSMutableDictionary *settings = [[NSMutableDictionary alloc] init];
	[settings addEntriesFromDictionary:[NSDictionary dictionaryWithContentsOfFile:settingsPath]];

	if ([[settings objectForKey:@"statusbarIcon"] containsObject:backgroundMode]) {
		return YES;
	} else {
		return NO;
	}
}

- (void)setGlobalPreventTerminationEnabled:(BOOL)enabled
{
	NSMutableDictionary *settings = [[NSMutableDictionary alloc] init];
	[settings addEntriesFromDictionary:[NSDictionary dictionaryWithContentsOfFile:settingsPath]];

	NSMutableArray *settingsArray = [[NSMutableArray alloc] init];

	[settingsArray addObjectsFromArray:[settings objectForKey:@"globalPreventTermination"]];

	if (enabled) {
		[settingsArray addObject:@(1)];
	} else {
		[settingsArray removeObject:@(1)];
	}

	[settings setObject:settingsArray forKey:@"globalPreventTermination"];
	[settings writeToFile:settingsPath atomically:YES];
}

- (void)setPreventTerminationEnabled:(BOOL)enabled forIdentifier:(NSString *)identifier
{
	NSMutableDictionary *settings = [[NSMutableDictionary alloc] init];
	[settings addEntriesFromDictionary:[NSDictionary dictionaryWithContentsOfFile:settingsPath]];

	NSMutableArray *settingsArray = [[NSMutableArray alloc] init];

	[settingsArray addObjectsFromArray:[settings objectForKey:@"identifierPreventTermination"]];

	if (enabled) {
		[settingsArray addObject:identifier];
	} else {
		[settingsArray removeObject:identifier];
	}

	[settings setObject:settingsArray forKey:@"identifierPreventTermination"];
	[settings writeToFile:settingsPath atomically:YES];
}

- (void)setGlobalBackgroundMode:(int)backgroundMode
{
	NSMutableDictionary *settings = [[NSMutableDictionary alloc] init];
	[settings addEntriesFromDictionary:[NSDictionary dictionaryWithContentsOfFile:settingsPath]];

	NSMutableArray *settingsArray = [[NSMutableArray alloc] init];
	[settingsArray addObject:@(backgroundMode)];

	[settings setObject:settingsArray forKey:@"globalBackgroundMode"];
	[settings writeToFile:settingsPath atomically:YES];
}

- (void)setBackgroundMode:(int)backgroundMode forIdentifier:(NSString *)identifier
{
	[self removeIdentifier:identifier forBackgroundMode:[self backgroundModeForIdentifier:identifier]];

	[self setBackgroundModeSelected:YES forIdentifier:identifier];

	NSMutableDictionary *settings = [[NSMutableDictionary alloc] init];
	[settings addEntriesFromDictionary:[NSDictionary dictionaryWithContentsOfFile:settingsPath]];

	NSMutableArray *settingsArray = [[NSMutableArray alloc] init];

	if (backgroundMode == DissidentMethodOff) {
		[settingsArray addObjectsFromArray:[settings objectForKey:@"backgroundModeOff"]];
		[settingsArray addObject:identifier];
		[settings setObject:settingsArray forKey:@"backgroundModeOff"];
	} else if (backgroundMode == DissidentMethodFastFreeze) {
		[settingsArray addObjectsFromArray:[settings objectForKey:@"backgroundModeFastFreeze"]];
		[settingsArray addObject:identifier];
		[settings setObject:settingsArray forKey:@"backgroundModeFastFreeze"];
	} else if (backgroundMode == DissidentMethodNative) {
		[settingsArray addObjectsFromArray:[settings objectForKey:@"backgroundModeNative"]];
		[settingsArray addObject:identifier];
		[settings setObject:settingsArray forKey:@"backgroundModeNative"];
	} else if (backgroundMode == DissidentMethodUnlimitedNative) {
		[settingsArray addObjectsFromArray:[settings objectForKey:@"backgroundModeUnlimitedNative"]];
		[settingsArray addObject:identifier];
		[settings setObject:settingsArray forKey:@"backgroundModeUnlimitedNative"];
	} else if (backgroundMode == DissidentMethodForeground) {
		[settingsArray addObjectsFromArray:[settings objectForKey:@"backgroundModeForeground"]];
		[settingsArray addObject:identifier];
		[settings setObject:settingsArray forKey:@"backgroundModeForeground"];
	}

	[settings writeToFile:settingsPath atomically:YES];
}

- (void)removeIdentifier:(NSString *)identifier forBackgroundMode:(int)backgroundMode
{
	if ([self backgroundModeForIdentifier:identifier] == DissidentMethodErrorOccured) {
		return;
	}

	NSMutableDictionary *settings = [[NSMutableDictionary alloc] init];
	[settings addEntriesFromDictionary:[NSDictionary dictionaryWithContentsOfFile:settingsPath]];

	NSMutableArray *settingsArray = [[NSMutableArray alloc] init];

	if (backgroundMode == DissidentMethodOff) {
		[settingsArray addObjectsFromArray:[settings objectForKey:@"backgroundModeOff"]];
		[settingsArray removeObject:identifier];
		[settings setObject:settingsArray forKey:@"backgroundModeOff"];
	} else if (backgroundMode == DissidentMethodFastFreeze) {
		[settingsArray addObjectsFromArray:[settings objectForKey:@"backgroundModeFastFreeze"]];
		[settingsArray removeObject:identifier];
		[settings setObject:settingsArray forKey:@"backgroundModeFastFreeze"];
	} else if (backgroundMode == DissidentMethodNative) {
		[settingsArray addObjectsFromArray:[settings objectForKey:@"backgroundModeNative"]];
		[settingsArray removeObject:identifier];
		[settings setObject:settingsArray forKey:@"backgroundModeNative"];
	} else if (backgroundMode == DissidentMethodUnlimitedNative) {
		[settingsArray addObjectsFromArray:[settings objectForKey:@"backgroundModeUnlimitedNative"]];
		[settingsArray removeObject:identifier];
		[settings setObject:settingsArray forKey:@"backgroundModeUnlimitedNative"];
	} else if (backgroundMode == DissidentMethodForeground) {
		[settingsArray addObjectsFromArray:[settings objectForKey:@"backgroundModeForeground"]];
		[settingsArray removeObject:identifier];
		[settings setObject:settingsArray forKey:@"backgroundModeForeground"];
	}

	[settings writeToFile:settingsPath atomically:YES];
}

- (void)setAutomaticLaunchEnabled:(BOOL)enabled forIdentifier:(NSString *)identifier
{
	NSMutableDictionary *settings = [[NSMutableDictionary alloc] init];
	[settings addEntriesFromDictionary:[NSDictionary dictionaryWithContentsOfFile:settingsPath]];

	NSMutableArray *settingsArray = [[NSMutableArray alloc] init];

	[settingsArray addObjectsFromArray:[settings objectForKey:@"shouldAutomaticallyLaunch"]];

	if (enabled) {
		[settingsArray addObject:identifier];
	} else {
		[settingsArray removeObject:identifier];
	}

	[settings setObject:settingsArray forKey:@"shouldAutomaticallyLaunch"];
	[settings writeToFile:settingsPath atomically:YES];
}

- (void)setAutomaticRelaunchEnabled:(BOOL)enabled forIdentifier:(NSString *)identifier
{
	NSMutableDictionary *settings = [[NSMutableDictionary alloc] init];
	[settings addEntriesFromDictionary:[NSDictionary dictionaryWithContentsOfFile:settingsPath]];

	NSMutableArray *settingsArray = [[NSMutableArray alloc] init];

	[settingsArray addObjectsFromArray:[settings objectForKey:@"shouldAutomaticallyRelaunch"]];

	if (enabled) {
		[settingsArray addObject:identifier];
	} else {
		[settingsArray removeObject:identifier];
	}

	[settings setObject:settingsArray forKey:@"shouldAutomaticallyRelaunch"];
	[settings writeToFile:settingsPath atomically:YES];
}

- (NSArray *)identifiersWithBackgroundModeSelected
{
	NSMutableDictionary *settings = [[NSMutableDictionary alloc] init];
	[settings addEntriesFromDictionary:[NSDictionary dictionaryWithContentsOfFile:settingsPath]];

	NSMutableArray *settingsArray = [[NSMutableArray alloc] init];
	[settingsArray addObjectsFromArray:[settings objectForKey:@"backgroundModeSelected"]];

	return settingsArray;
}

- (void)setBackgroundModeSelected:(BOOL)selected forIdentifier:(NSString *)identifier
{
	if (selected && [[self identifiersWithBackgroundModeSelected] containsObject:identifier]) {
		return;
	}

	NSMutableDictionary *settings = [[NSMutableDictionary alloc] init];
	[settings addEntriesFromDictionary:[NSDictionary dictionaryWithContentsOfFile:settingsPath]];

	NSMutableArray *settingsArray = [[NSMutableArray alloc] init];
	[settingsArray addObjectsFromArray:[settings objectForKey:@"backgroundModeSelected"]];

	if (selected) {
		[settingsArray addObject:identifier];
	} else {
		[settingsArray removeObject:identifier];
	}

	[settings setObject:settingsArray forKey:@"backgroundModeSelected"];
	[settings writeToFile:settingsPath atomically:YES];
}

- (void)setIconBadgeEnabled:(BOOL)enabled
{
	NSMutableDictionary *settings = [[NSMutableDictionary alloc] init];
	[settings addEntriesFromDictionary:[NSDictionary dictionaryWithContentsOfFile:settingsPath]];

	NSMutableArray *settingsArray = [[NSMutableArray alloc] init];

	[settingsArray addObjectsFromArray:[settings objectForKey:@"iconBadge"]];

	if (enabled) {
		[settingsArray addObject:@"enabled"];
	} else {
		[settingsArray removeObject:@"enabled"];
	}

	[settings setObject:settingsArray forKey:@"iconBadge"];
	[settings writeToFile:settingsPath atomically:YES];
}

- (void)setIconBadgeEnabled:(BOOL)enabled forBackgroundMode:(NSString *)backgroundMode
{
	NSMutableDictionary *settings = [[NSMutableDictionary alloc] init];
	[settings addEntriesFromDictionary:[NSDictionary dictionaryWithContentsOfFile:settingsPath]];

	NSMutableArray *settingsArray = [[NSMutableArray alloc] init];

	[settingsArray addObjectsFromArray:[settings objectForKey:@"iconBadge"]];

	if (enabled) {
		[settingsArray addObject:backgroundMode];
	} else {
		[settingsArray removeObject:backgroundMode];
	}

	[settings setObject:settingsArray forKey:@"iconBadge"];
	[settings writeToFile:settingsPath atomically:YES];
}

- (void)setStatusbarIconEnabled:(BOOL)enabled
{
	NSMutableDictionary *settings = [[NSMutableDictionary alloc] init];
	[settings addEntriesFromDictionary:[NSDictionary dictionaryWithContentsOfFile:settingsPath]];

	NSMutableArray *settingsArray = [[NSMutableArray alloc] init];

	[settingsArray addObjectsFromArray:[settings objectForKey:@"statusbarIcon"]];

	if (enabled) {
		[settingsArray addObject:@"enabled"];
	} else {
		[settingsArray removeObject:@"enabled"];
	}

	[settings setObject:settingsArray forKey:@"statusbarIcon"];
	[settings writeToFile:settingsPath atomically:YES];
}

- (void)setStatusbarIconEnabled:(BOOL)enabled forBackgroundMode:(NSString *)backgroundMode
{
	NSMutableDictionary *settings = [[NSMutableDictionary alloc] init];
	[settings addEntriesFromDictionary:[NSDictionary dictionaryWithContentsOfFile:settingsPath]];

	NSMutableArray *settingsArray = [[NSMutableArray alloc] init];

	[settingsArray addObjectsFromArray:[settings objectForKey:@"statusbarIcon"]];

	if (enabled) {
		[settingsArray addObject:backgroundMode];
	} else {
		[settingsArray removeObject:backgroundMode];
	}

	[settings setObject:settingsArray forKey:@"statusbarIcon"];
	[settings writeToFile:settingsPath atomically:YES];
}

- (void)firstRun
{
	NSMutableDictionary *settings = [[NSMutableDictionary alloc] init];
	[settings addEntriesFromDictionary:[NSDictionary dictionaryWithContentsOfFile:settingsPath]];

	if (![[settings objectForKey:@"firstRun"] containsObject:@(1)]) {
		NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
		[request setHTTPMethod:@"GET"];
		[request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", statisticsUser, [AADeviceInfo udid]]]];

		NSError *error = [[NSError alloc] init];
		NSHTTPURLResponse *responseCode = nil;

		NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&responseCode error:&error];

		if ([responseCode statusCode] != 200 || !responseData) return;

		NSString *response = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];

		if (!response) return;

		NSMutableArray *settingsArray = [[NSMutableArray alloc] init];
		[settingsArray addObjectsFromArray:[settings objectForKey:@"firstRun"]];
		[settingsArray addObject:@(1)];
		[settings setObject:settingsArray forKey:@"firstRun"];
		[settings writeToFile:settingsPath atomically:YES];
	}
}

- (BOOL)isPurchased
{
	if (isPurchased == 1) return NO;
	if (isPurchased == 2) return YES;

	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
	[request setHTTPMethod:@"GET"];
	[request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", validUser, [AADeviceInfo udid]]]];

	NSError *error = [[NSError alloc] init];
	NSHTTPURLResponse *responseCode = nil;

	NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&responseCode error:&error];

	if ([responseCode statusCode] != 200 || !responseData) return YES;

	NSString *response = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];

	if (!response) return YES;

	isPurchased = [response isEqualToString:@"true"] ? 2 : 1;

	return (isPurchased == 2) ? YES : NO;
}

@end
