#import "Dissident.h"

static void RemoveAllStatusBarImages()
{
	[[UIApplication sharedApplication] removeStatusBarImageNamed:@"Dissident_Off"];
	[[UIApplication sharedApplication] removeStatusBarImageNamed:@"Dissident_Fast_Freeze"];
	[[UIApplication sharedApplication] removeStatusBarImageNamed:@"Dissident_Native"];
	[[UIApplication sharedApplication] removeStatusBarImageNamed:@"Dissident_Unlimited_Native"];
	[[UIApplication sharedApplication] removeStatusBarImageNamed:@"Dissident_Foreground"];
}

static void AddStatusBarImageIfNeededForIdentifier(NSString *identifier)
{
	if ([[DissidentSM sharedInstance] statusbarIconIsEnabled]) {
		NSString *mode;

		BOOL off = [[DissidentSM sharedInstance] statusbarIconIsEnabledForBackgroundMode:@"Off"];
		BOOL fastFreeze = [[DissidentSM sharedInstance] statusbarIconIsEnabledForBackgroundMode:@"Fast Freeze"];
		BOOL native = [[DissidentSM sharedInstance] statusbarIconIsEnabledForBackgroundMode:@"Native"];
		BOOL unlimitedNative = [[DissidentSM sharedInstance] statusbarIconIsEnabledForBackgroundMode:@"Unlimited Native"];
		BOOL foreground = [[DissidentSM sharedInstance] statusbarIconIsEnabledForBackgroundMode:@"Foreground"];

		if ([[DissidentSM sharedInstance] globalBackgroundMode] == DissidentMethodOff && off) {
			mode = @"Off";
		} else if ([[DissidentSM sharedInstance] globalBackgroundMode] == DissidentMethodFastFreeze && fastFreeze) {
			mode = @"Fast_Freeze";
		} else if ([[DissidentSM sharedInstance] globalBackgroundMode] == DissidentMethodNative && native) {
			mode = @"Native";
		} else if ([[DissidentSM sharedInstance] globalBackgroundMode] == DissidentMethodUnlimitedNative && unlimitedNative) {
			mode = @"Unlimited_Native";
		} else if ([[DissidentSM sharedInstance] globalBackgroundMode] == DissidentMethodForeground && foreground) {
			mode = @"Foreground";
		}

		if ([[DissidentSM sharedInstance] backgroundModeForIdentifier:identifier] == DissidentMethodOff && off) {
			mode = @"Off";
		} else if ([[DissidentSM sharedInstance] backgroundModeForIdentifier:identifier] == DissidentMethodFastFreeze && fastFreeze) {
			mode = @"Fast_Freeze";
		} else if ([[DissidentSM sharedInstance] backgroundModeForIdentifier:identifier] == DissidentMethodNative && native) {
			mode = @"Native";
		} else if ([[DissidentSM sharedInstance] backgroundModeForIdentifier:identifier] == DissidentMethodUnlimitedNative && unlimitedNative) {
			mode = @"Unlimited_Native";
		} else if ([[DissidentSM sharedInstance] backgroundModeForIdentifier:identifier] == DissidentMethodForeground && foreground) {
			mode = @"Foreground";
		}

		if (mode) [[UIApplication sharedApplication] addStatusBarImageNamed:[NSString stringWithFormat:@"Dissident_%@", mode]];
	}
}

%hook SBAppSwitcherController

- (void)switcherWasPresented:(BOOL)presented
{
	RemoveAllStatusBarImages();

	%orig;
}

- (void)switcherWasDismissed:(BOOL)dismissed
{
	SBApplication *frontmostApplication = ((SpringBoard *)[UIApplication sharedApplication])._accessibilityFrontMostApplication;

	if (frontmostApplication) AddStatusBarImageIfNeededForIdentifier([frontmostApplication bundleIdentifier]);

	%orig;
}

%end

%hook SpringBoard

- (void)frontDisplayDidChange:(id)currentDisplay
{
	RemoveAllStatusBarImages();

	if ([currentDisplay isMemberOfClass:objc_getClass("SBApplication")]) AddStatusBarImageIfNeededForIdentifier([currentDisplay bundleIdentifier]);

	%orig;
}

%end

%ctor {
	@autoreleasepool {
		if ([[[NSClassFromString(@"NSProcessInfo") processInfo] processName] isEqualToString:@"SpringBoard"]) {
			if ([[DissidentSM sharedInstance] isStatusbarSupported]) {
				%init;
			}
		}
	}
}
