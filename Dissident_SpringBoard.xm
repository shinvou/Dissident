#import "Dissident.h"

static NSMutableDictionary *identifiersToRevert;

%hook SBLockScreenManager

- (void)_finishUIUnlockFromSource:(int)source withOptions:(id)options
{
	%orig;

	if (![[[NSDictionary dictionaryWithContentsOfFile:settingsPath] objectForKey:@"firstRun"] containsObject:@(1)]) {
		[[DissidentSM sharedInstance] firstRun];

		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"Hei. Thanks for using Dissident. To configure Dissident, please open its seperate application. You'll find it on your homescreen, probably on the last page of the homescreen." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
		[alert show];
	}
}

%end

%hook SBApplication

- (void)processDidLaunch:(FBApplicationProcess *)process
{
	%orig;

	NSString *bundleIdentifier = [self bundleIdentifier];

	[[DissidentHelper sharedInstance] refreshBackgroundingEnabled:YES forIdentifier:bundleIdentifier];

	if ([identifiersToRevert objectForKey:bundleIdentifier]) {
		NSNumber *backgroundMode = [identifiersToRevert objectForKey:bundleIdentifier];

		[self performSelector:@selector(revertToBackgroundMode:) withObject:backgroundMode afterDelay:4.0];

		[identifiersToRevert removeObjectForKey:bundleIdentifier];
	}
}

- (BOOL)_shouldAutoLaunchOnBootOrInstall:(BOOL)install
{
	if ([[DissidentSM sharedInstance] identifierHasAutomaticLaunchSettings:[self bundleIdentifier]]) {
		if ([[DissidentSM sharedInstance] backgroundModeForIdentifier:[self bundleIdentifier]] == DissidentMethodOff) {
			return %orig;
		}

		int backgroundMode = [[DissidentSM sharedInstance] backgroundModeForIdentifier:[self bundleIdentifier]];

		if (backgroundMode == DissidentMethodFastFreeze || backgroundMode == DissidentMethodNative || backgroundMode == DissidentMethodUnlimitedNative) {
			if (!identifiersToRevert) identifiersToRevert = [[NSMutableDictionary alloc] init];

			if (![identifiersToRevert objectForKey:[self bundleIdentifier]]) [identifiersToRevert setObject:@(backgroundMode) forKey:[self bundleIdentifier]];

			[[DissidentSM sharedInstance] setBackgroundMode:DissidentMethodForeground forIdentifier:[self bundleIdentifier]];
		}

		return YES;
	}

	return %orig;
}

- (BOOL)shouldAutoRelaunchAfterExit
{
	if ([[DissidentSM sharedInstance] identifierHasAutomaticRelaunchSettings:[self bundleIdentifier]]) {
		if ([[DissidentSM sharedInstance] backgroundModeForIdentifier:[self bundleIdentifier]] == DissidentMethodOff) {
			return %orig;
		} else if ([[DissidentSM sharedInstance] globalBackgroundMode] == DissidentMethodOff) {
			if ([[DissidentSM sharedInstance] backgroundModeForIdentifier:[self bundleIdentifier]] == DissidentMethodErrorOccured) {
				return %orig;
			}
		}

		return YES;
	}

	return %orig;
}

%new - (void)revertToBackgroundMode:(NSNumber *)backgroundMode
{
	int mode = [backgroundMode intValue];
	NSString *bundleIdentifier = [self bundleIdentifier];

	BOOL fastFreeze = [[DissidentSM sharedInstance] iconBadgeIsEnabledForBackgroundMode:@"Fast Freeze"];
	BOOL native = [[DissidentSM sharedInstance] iconBadgeIsEnabledForBackgroundMode:@"Native"];
	BOOL unlimitedNative = [[DissidentSM sharedInstance] iconBadgeIsEnabledForBackgroundMode:@"Unlimited Native"];

	SBIcon *icon = [[[objc_getClass("SBIconController") sharedInstance] model] expectedIconForDisplayIdentifier:bundleIdentifier];
	SBIconView *iconView = [[objc_getClass("SBIconViewMap") homescreenMap] mappedIconViewForIcon:icon];

	if ([iconView viewWithTag:1337]) [iconView viewWithTag:1337].backgroundColor = [UIColor clearColor];

	if (mode == DissidentMethodFastFreeze && fastFreeze) {
		if ([iconView viewWithTag:1337]) [iconView viewWithTag:1337].backgroundColor = [UIColor whiteColor];
	} else if (mode == DissidentMethodNative && native) {
		if ([iconView viewWithTag:1337]) [iconView viewWithTag:1337].backgroundColor = [UIColor lightGrayColor];
	} else if (mode == DissidentMethodUnlimitedNative && unlimitedNative) {
		if ([iconView viewWithTag:1337]) [iconView viewWithTag:1337].backgroundColor = [UIColor darkGrayColor];
	}

	[[DissidentHelper sharedInstance] stopBackgroundingForIdentifier:bundleIdentifier];
	[[DissidentSM sharedInstance] setBackgroundMode:mode forIdentifier:bundleIdentifier];
	[[DissidentHelper sharedInstance] refreshBackgroundingEnabled:YES forIdentifier:bundleIdentifier];
}

%end

%ctor {
	@autoreleasepool {
		if ([[[NSClassFromString(@"NSProcessInfo") processInfo] processName] isEqualToString:@"SpringBoard"]) {
			%init;

			if ([[DissidentSM sharedInstance] isActivatorSupported]) {
				[[DissidentActivatorInitializer sharedInstance] initializeActivatorActions];
			}
		}
	}
}
