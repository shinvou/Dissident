#import "Dissident.h"

static NSMutableArray *exceptions;

%hook SBUIController

- (void)_noteAppDidActivate:(SBApplication *)application
{
	[application clearDeactivationSettings];

	%orig;
}

%end

%hook FBSSceneImpl

- (id)_initWithQueue:(id)arg1 callOutQueue:(id)arg2 identifier:(id)arg3 display:(id)arg4 settings:(id)settings clientSettings:(id)arg6
{
	if (!settings) settings = [[objc_getClass("UIMutableApplicationSceneSettings") alloc] init];

	return %orig;
}

%end

%hook FBApplicationProcess

- (void)killForReason:(int)arg1 andReport:(BOOL)arg2 withDescription:(id)arg3 completion:(id)arg4
{
	/* Determine which reason is App Store Update */

	if ([[DissidentSM sharedInstance] identifierHasPreventTerminationSettings:[self bundleIdentifier]]) {
		return;
	} else if ([[DissidentSM sharedInstance] globalHasPreventTerminationSettings]) {
		if ([[[DissidentSM sharedInstance] identifiersWithBackgroundModeSelected] containsObject:[self bundleIdentifier]] && ![[DissidentSM sharedInstance] identifierHasPreventTerminationSettings:[self bundleIdentifier]]) {
			goto NOPREVENTION;
		}

		return;
	}

NOPREVENTION:

	if ([[DissidentSM sharedInstance] backgroundModeForIdentifier:[self bundleIdentifier]] == DissidentMethodUnlimitedNative) {
		[[DissidentHelper sharedInstance] removeAssertionForIdentifier:[self bundleIdentifier]];
	} else if ([[DissidentSM sharedInstance] globalBackgroundMode] == DissidentMethodUnlimitedNative) {
		if ([[DissidentSM sharedInstance] backgroundModeForIdentifier:[self bundleIdentifier]] == DissidentMethodErrorOccured) {
			[[DissidentHelper sharedInstance] removeAssertionForIdentifier:[self bundleIdentifier]];
		}
	}

	if ([[DissidentSM sharedInstance] backgroundModeForIdentifier:[self bundleIdentifier]] == DissidentMethodForeground) {
		[[DissidentHelper sharedInstance] stopBackgroundingForIdentifier:[self bundleIdentifier]];
	} else if ([[DissidentSM sharedInstance] globalBackgroundMode] == DissidentMethodForeground) {
		if ([[DissidentSM sharedInstance] backgroundModeForIdentifier:[self bundleIdentifier]] == DissidentMethodErrorOccured) {
			[[DissidentHelper sharedInstance] stopBackgroundingForIdentifier:[self bundleIdentifier]];
		}
	}

	if ([exceptions containsObject:[self bundleIdentifier]]) [exceptions removeObject:[self bundleIdentifier]];

	%orig;
}

%end

%hook FBUIApplicationWorkspaceScene

- (void)host:(id)arg1 didUpdateSettings:(FBSSceneSettings *)sceneSettings withDiff:(id)arg3 transitionContext:(id)arg4 completion:(id)arg5
{
	if ([sceneSettings isBackgrounded] && [exceptions containsObject:[arg1 identifier]]) return;

	if ([sceneSettings isBackgrounded] && [[DissidentSM sharedInstance] backgroundModeForIdentifier:[arg1 identifier]] == DissidentMethodForeground) {
		return;
	} else if ([sceneSettings isBackgrounded] && [[DissidentSM sharedInstance] globalBackgroundMode] == DissidentMethodForeground) {
		if ([[DissidentSM sharedInstance] backgroundModeForIdentifier:[arg1 identifier]] == DissidentMethodErrorOccured) {
			return;
		}
	}

	%orig;
}

%new - (void)toggleTemporaryEnabledForIdentifier:(NSString *)identifier
{
	if (!exceptions) exceptions = [[NSMutableArray alloc] init];

	if ([exceptions containsObject:identifier]) {
		[exceptions removeObject:identifier];
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Dissident" message:@"Foregrounding disabled." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    [alert show];
	} else {
		[exceptions addObject:identifier];
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Dissident" message:@"Foregrounding enabled." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    [alert show];
	}
}

%end

%hook FBUIApplicationResignActiveManager

- (void)_sendResignActiveForReason:(int)arg1 toProcess:(FBApplicationProcess *)applicationProcess
{
	if ([[DissidentSM sharedInstance] backgroundModeForIdentifier:[applicationProcess bundleIdentifier]] == DissidentMethodFastFreeze) {
		[self sendManualSuspendToProcess:applicationProcess];
	} else if ([[DissidentSM sharedInstance] globalBackgroundMode] == DissidentMethodFastFreeze) {
		if ([[DissidentSM sharedInstance] backgroundModeForIdentifier:[applicationProcess bundleIdentifier]] == DissidentMethodErrorOccured) {
			[self sendManualSuspendToProcess:applicationProcess];
		}
	}

	if ([[DissidentSM sharedInstance] backgroundModeForIdentifier:[applicationProcess bundleIdentifier]] == DissidentMethodForeground) {
		return;
	} else if ([[DissidentSM sharedInstance] globalBackgroundMode] == DissidentMethodForeground) {
		if ([[DissidentSM sharedInstance] backgroundModeForIdentifier:[applicationProcess bundleIdentifier]] == DissidentMethodErrorOccured) {
			return;
		}
	}

	%orig;
}

%new - (void)sendManualSuspendToProcess:(FBApplicationProcess *)applicationProcess
{
	BKSProcess *applicationBKSProcess = MSHookIvar<BKSProcess *>(applicationProcess, "_bksProcess");
	[applicationBKSProcess performSelector:@selector(_handleExpirationWarning:) withObject:nil afterDelay:5.0];
}

%end

%hook UIApplication

- (void)_setSuspended:(BOOL)arg1
{
	if ([[DissidentSM sharedInstance] backgroundModeForIdentifier:[self displayIdentifier]] == DissidentMethodOff) {
		UIApplicationFlags8x &_applicationFlags = MSHookIvar<UIApplicationFlags8x>(self, "_applicationFlags");
		_applicationFlags.taskSuspendingUnsupported = 1;
		_applicationFlags.taskSuspendingOnLockUnsupported = 1;
	} else if ([[DissidentSM sharedInstance] globalBackgroundMode] == DissidentMethodOff) {
		if ([[DissidentSM sharedInstance] backgroundModeForIdentifier:[self displayIdentifier]] == DissidentMethodErrorOccured) {
			UIApplicationFlags8x &_applicationFlags = MSHookIvar<UIApplicationFlags8x>(self, "_applicationFlags");
			_applicationFlags.taskSuspendingUnsupported = 1;
			_applicationFlags.taskSuspendingOnLockUnsupported = 1;
		}
	}

	%orig;
}

%end
