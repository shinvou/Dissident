#import "DissidentActivatorActionToggleForcedBackgroundingTemporary.h"

@implementation DissidentActivatorActionToggleForcedBackgroundingTemporary

- (NSString *)activator:(LAActivator *)activator requiresLocalizedGroupForListenerName:(NSString *)listenerName
{
  return @"Dissident";
}

- (NSString *)activator:(id)activator requiresLocalizedTitleForListenerName:(NSString *)listenerName
{
  return @"Toggle Foregrounding Temporary";
}

- (NSString *)activator:(id)activator requiresLocalizedDescriptionForListenerName:(NSString *)listenerName
{
  return @"Toggle foregrounding for currently open app, but don't save the backgrounding mode to settings";
}

- (void)activator:(LAActivator *)activator receiveEvent:(LAEvent *)event
{
  if (((SpringBoard *)[UIApplication sharedApplication])._accessibilityFrontMostApplication) {
    NSString *identifier = [((SpringBoard *)[UIApplication sharedApplication])._accessibilityFrontMostApplication bundleIdentifier];

    FBScene *scene = [[objc_getClass("FBSceneManager") sharedInstance] sceneWithIdentifier:identifier];
    NSObject <FBSceneClient> *sceneClient = [scene client];
    [sceneClient toggleTemporaryEnabledForIdentifier:identifier];
  }

  [event setHandled:YES];
}

- (UIImage *)activator:(LAActivator *)activator requiresSmallIconForListenerName:(NSString *)listenerName scale:(CGFloat)scale
{
  return [UIImage imageWithContentsOfFile:@"/Library/Application Support/Dissident/Icon29_r.png"];
}

@end
