#import "DissidentActivatorActionToggleForcedBackgrounding.h"

@implementation DissidentActivatorActionToggleForcedBackgrounding

- (NSString *)activator:(LAActivator *)activator requiresLocalizedGroupForListenerName:(NSString *)listenerName
{
  return @"Dissident";
}

- (NSString *)activator:(id)activator requiresLocalizedTitleForListenerName:(NSString *)listenerName
{
  return @"Toggle Foregrounding Permanent";
}

- (NSString *)activator:(id)activator requiresLocalizedDescriptionForListenerName:(NSString *)listenerName
{
  return @"Toggle foregrounding for currently open app and write backgrounding mode to settings";
}

- (void)activator:(LAActivator *)activator receiveEvent:(LAEvent *)event
{
  if (((SpringBoard *)[UIApplication sharedApplication])._accessibilityFrontMostApplication) {
    NSString *identifier = [((SpringBoard *)[UIApplication sharedApplication])._accessibilityFrontMostApplication bundleIdentifier];
    int backgroundMode = [[objc_getClass("DissidentSM") sharedInstance] backgroundModeForIdentifier:identifier];

    backgroundMode = (backgroundMode == 4) ? 2 : 4;

    [[objc_getClass("DissidentSM") sharedInstance] setBackgroundMode:backgroundMode forIdentifier:identifier];

    if (backgroundMode == 4) {
      [[objc_getClass("DissidentHelper") sharedInstance] refreshBackgroundingEnabled:YES forIdentifier:identifier];

      UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Dissident" message:@"Foregrounding enabled." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
      [alert show];
    } else {
      [[objc_getClass("DissidentHelper") sharedInstance] refreshBackgroundingEnabled:YES forIdentifier:identifier];

      UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Dissident" message:@"Foregrounding disabled." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
      [alert show];
    }
  }

  [event setHandled:YES];
}

- (UIImage *)activator:(LAActivator *)activator requiresSmallIconForListenerName:(NSString *)listenerName scale:(CGFloat)scale
{
  return [UIImage imageWithContentsOfFile:@"/Library/Application Support/Dissident/Icon29_r.png"];
}

@end
