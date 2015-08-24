#import "Dissident.h"

@implementation DissidentHelper

+ (id)sharedInstance
{
	static DissidentHelper *sharedInstance;

	static dispatch_once_t provider_token;
	dispatch_once(&provider_token, ^{
		sharedInstance = [[self alloc] init];
		sharedInstance.assertions = [[NSMutableDictionary alloc] init];
	});

	return sharedInstance;
}

- (void)addAssertionForIdentifier:(NSString *)identifier
{
	if ([_assertions objectForKey:identifier] && [[_assertions objectForKey:identifier] valid]) return;

	BKSProcessAssertion *assertion = [[BKSProcessAssertion alloc] initWithBundleIdentifier:identifier flags:0xF reason:7 name:[NSString stringWithFormat:@"%@_from_dissident", identifier] withHandler:^void() {
		log(@"Added unlimited assertion to %@.", identifier);
	}];

	[_assertions setObject:assertion forKey:identifier];
}

- (void)removeAssertionForIdentifier:(NSString *)identifier
{
	if ([_assertions objectForKey:identifier]) {
		[[_assertions objectForKey:identifier] invalidate];
		[_assertions removeObjectForKey:identifier];
	}
}

- (void)startBackgroundingForIdentifier:(NSString *)identifier
{
	FBScene *scene = [[objc_getClass("FBSceneManager") sharedInstance] sceneWithIdentifier:identifier];
	NSObject <FBSceneClientProvider> *clientProvider = [scene clientProvider];
	NSObject <FBSceneClient> *sceneClient = [scene client];
	FBSSceneSettings *sceneSettings = [[scene settings] mutableCopy];
	[sceneSettings setBackgrounded:NO];
	FBSSceneSettingsDiff *sceneSettingsDiff = [objc_getClass("FBSSceneSettingsDiff") diffFromSettings:[scene settings] toSettings:sceneSettings];
	[clientProvider beginTransaction];
	[sceneClient host:scene didUpdateSettings:sceneSettings withDiff:sceneSettingsDiff transitionContext:0 completion:nil];
	[clientProvider endTransaction];
}

- (void)stopBackgroundingForIdentifier:(NSString *)identifier
{
	FBScene *scene = [[objc_getClass("FBSceneManager") sharedInstance] sceneWithIdentifier:identifier];
	NSObject <FBSceneClientProvider> *clientProvider = [scene clientProvider];
	NSObject <FBSceneClient> *sceneClient = [scene client];
	FBSSceneSettings *sceneSettings = [[scene settings] mutableCopy];
	[sceneSettings setBackgrounded:YES];
	FBSSceneSettingsDiff *sceneSettingsDiff = [objc_getClass("FBSSceneSettingsDiff") diffFromSettings:[scene settings] toSettings:sceneSettings];
	[clientProvider beginTransaction];
	[sceneClient host:scene didUpdateSettings:sceneSettings withDiff:sceneSettingsDiff transitionContext:0 completion:nil];
	[clientProvider endTransaction];
}

- (void)refreshBackgroundingEnabled:(BOOL)enabled forIdentifier:(NSString *)identifier
{
	if ([[DissidentSM sharedInstance] backgroundModeForIdentifier:identifier] == DissidentMethodUnlimitedNative) {
		if (enabled) {
			SBApplication *application = [[objc_getClass("SBApplicationController") sharedInstance] applicationWithBundleIdentifier:identifier];
			if (![application isRunning]) {
				[[objc_getClass("UIApplication") sharedApplication] launchApplicationWithIdentifier:identifier suspended:YES];
			}

			[self addAssertionForIdentifier:identifier];
		} else {
			[self removeAssertionForIdentifier:identifier];
		}
	} else if ([[DissidentSM sharedInstance] backgroundModeForIdentifier:identifier] == DissidentMethodForeground) {
		if (enabled) {
			SBApplication *application = [[objc_getClass("SBApplicationController") sharedInstance] applicationWithBundleIdentifier:identifier];
			if (![application isRunning]) {
				[[objc_getClass("UIApplication") sharedApplication] launchApplicationWithIdentifier:identifier suspended:YES];
			}

			[self startBackgroundingForIdentifier:identifier];
		} else {
			[self stopBackgroundingForIdentifier:identifier];
		}
	}
}

@end
