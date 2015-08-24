#import "Dissident.h"

static NSMutableArray *runningApplications;

static void SetIndicator(SBIconView *iconView, NSString *currentIdentifier)
{
	UIView *iconIndicator = [[UIView alloc] initWithFrame:CGRectMake(-8, 46, 20, 20)];
	iconIndicator.layer.cornerRadius = 10;

	BOOL fastFreeze = [[DissidentSM sharedInstance] iconBadgeIsEnabledForBackgroundMode:@"Fast Freeze"];
	BOOL native = [[DissidentSM sharedInstance] iconBadgeIsEnabledForBackgroundMode:@"Native"];
	BOOL unlimitedNative = [[DissidentSM sharedInstance] iconBadgeIsEnabledForBackgroundMode:@"Unlimited Native"];
	BOOL foreground = [[DissidentSM sharedInstance] iconBadgeIsEnabledForBackgroundMode:@"Foreground"];

	if ([[DissidentSM sharedInstance] globalBackgroundMode] == DissidentMethodFastFreeze && fastFreeze) {
		iconIndicator.backgroundColor = [UIColor whiteColor];
	} else if ([[DissidentSM sharedInstance] globalBackgroundMode] == DissidentMethodNative && native) {
		iconIndicator.backgroundColor = [UIColor lightGrayColor];
	} else if ([[DissidentSM sharedInstance] globalBackgroundMode] == DissidentMethodUnlimitedNative && unlimitedNative) {
		iconIndicator.backgroundColor = [UIColor darkGrayColor];
	} else if ([[DissidentSM sharedInstance] globalBackgroundMode] == DissidentMethodForeground && foreground) {
		iconIndicator.backgroundColor = [UIColor blackColor];
	}

	if ([[DissidentSM sharedInstance] backgroundModeForIdentifier:currentIdentifier] == DissidentMethodOff) {
		iconIndicator.backgroundColor = [UIColor clearColor];
	} else if ([[DissidentSM sharedInstance] backgroundModeForIdentifier:currentIdentifier] == DissidentMethodFastFreeze && fastFreeze) {
		iconIndicator.backgroundColor = [UIColor whiteColor];
	} else if ([[DissidentSM sharedInstance] backgroundModeForIdentifier:currentIdentifier] == DissidentMethodNative && native) {
		iconIndicator.backgroundColor = [UIColor lightGrayColor];
	} else if ([[DissidentSM sharedInstance] backgroundModeForIdentifier:currentIdentifier] == DissidentMethodUnlimitedNative && unlimitedNative) {
		iconIndicator.backgroundColor = [UIColor darkGrayColor];
	} else if ([[DissidentSM sharedInstance] backgroundModeForIdentifier:currentIdentifier] == DissidentMethodForeground && foreground) {
		iconIndicator.backgroundColor = [UIColor blackColor];
	}

	[iconIndicator setTag:1337];
	[iconView addSubview:iconIndicator];
}

%hook FBApplicationProcess

- (void)killForReason:(int)arg1 andReport:(BOOL)arg2 withDescription:(id)arg3 completion:(id)arg4
{
	SBIcon *icon = [[[objc_getClass("SBIconController") sharedInstance] model] expectedIconForDisplayIdentifier:[self bundleIdentifier]];
	SBIconView *iconView = [[objc_getClass("SBIconViewMap") homescreenMap] mappedIconViewForIcon:icon];

	if ([iconView viewWithTag:1337]) [[iconView viewWithTag:1337] removeFromSuperview];

	if ([runningApplications containsObject:[self bundleIdentifier]]) [runningApplications removeObject:[self bundleIdentifier]];

	%orig;
}

%end

%hook SBIconView

-(id)_iconImageView
{
	SBIconView *iconView = %orig;

	NSString *currentIdentifier = [[self icon] leafIdentifier];

	if ([[DissidentSM sharedInstance] iconBadgeIsEnabled]) {
		if ([iconView viewWithTag:1337]) [[iconView viewWithTag:1337] removeFromSuperview];

		if (currentIdentifier && [runningApplications containsObject:currentIdentifier]) SetIndicator(iconView, currentIdentifier);
	}

	return iconView;
}

%end

%hook SBApplication

-(void)processDidLaunch:(id)process
{
	NSString *currentIdentifier = [self bundleIdentifier];

	if ([[DissidentSM sharedInstance] iconBadgeIsEnabled]) {
		SBIcon *icon = [[[objc_getClass("SBIconController") sharedInstance] model] expectedIconForDisplayIdentifier:currentIdentifier];
		SBIconView *iconView = [[objc_getClass("SBIconViewMap") homescreenMap] mappedIconViewForIcon:icon];

		if ([iconView viewWithTag:1337]) [[iconView viewWithTag:1337] removeFromSuperview];

		SetIndicator(iconView, currentIdentifier);
	}

	if (![runningApplications containsObject:currentIdentifier]) [runningApplications addObject:currentIdentifier];

	%orig;
}

%end

%ctor {
	@autoreleasepool {
		if ([[[NSClassFromString(@"NSProcessInfo") processInfo] processName] isEqualToString:@"SpringBoard"]) {
			%init;
			runningApplications = [[NSMutableArray alloc] init];
		}
	}
}
