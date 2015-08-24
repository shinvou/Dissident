#import "../Dissident.h"

static id _dissidentWindow = nil;
static id _springboardWindow = nil;
static id _navigationController = nil;

static void PushView(UIView *view)
{
	[UIView animateWithDuration:0.1 animations:^{
		[view setTransform:CGAffineTransformMakeScale(1 - .1, 1 - .1)];
	} completion:^(BOOL finished){
		[UIView animateWithDuration:0.1 animations:^{
			[view setTransform:CGAffineTransformMakeScale(1 + .05, 1 + .05)];
		} completion:^(BOOL finished){
			[UIView animateWithDuration:0.1 animations:^{
				[view setTransform:CGAffineTransformMakeScale(1, 1)];
			}];
		}];
	}];
}

static void PopView(UIView *view)
{
	[UIView animateWithDuration:0.1 animations:^{
		[view setTransform:CGAffineTransformMakeScale(1 + .05, 1 + .05)];
	} completion:^(BOOL finished){
		[UIView animateWithDuration:0.2 animations:^{
			[view setTransform:CGAffineTransformMakeScale(1 - .6, 1 - .6)];
		} completion:^(BOOL finished){
			[UIView animateWithDuration:0.2 animations:^{
				[view setTransform:CGAffineTransformMakeScale(2, 2)];
				[view setAlpha:0];
			} completion:^(BOOL finished){
				[view removeFromSuperview];
			}];
		}];
	}];
}

%hook SBIconController

%new - (void)initializeSettings
{
	BOOL isPurchased = [[objc_getClass("DissidentSM") sharedInstance] isPurchased];

	_dissidentWindow = [[DissidentWindow alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight + 20)];
	DissidentSettings *dissidentSettings = [[DissidentSettings alloc] init];
	_navigationController = [[UINavigationController alloc] initWithRootViewController:dissidentSettings];
	[[_navigationController view] setFrame:CGRectMake(0, 20, kScreenWidth, kScreenHeight)];

	if (!isPurchased) {
		dispatch_async(dispatch_get_main_queue(), ^(void){
			GADBannerView *bannerView = [[GADBannerView alloc] init];
			[bannerView setFrame:CGRectMake(0, [[_navigationController view] frame].size.height - 70, [[_navigationController view] frame].size.width, 50)];
			[[_navigationController view] addSubview:bannerView];
			bannerView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin);
			bannerView.adUnitID = @"ca-app-pub-8745569730825579/9979009922";
			bannerView.rootViewController = (UIViewController *)_navigationController;
			[bannerView loadRequest:[GADRequest request]];
    });
	}

	[_dissidentWindow addSubview:[_navigationController view]];

	UIView *statusbarView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 20)];
	statusbarView.backgroundColor = UIColorRGB(74, 74, 74);
	UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickedStatusbar:)];
	if (!isPurchased) [statusbarView addGestureRecognizer:tapGestureRecognizer];

	UILabel *thanks = [[UILabel alloc] initWithFrame:statusbarView.frame];
	thanks.text = isPurchased ? @"Thank you for your purchase." : @"Are you seeing ads? Click me.";
	thanks.textColor = [UIColor whiteColor];
	thanks.textAlignment = NSTextAlignmentCenter;
	thanks.adjustsFontSizeToFitWidth = YES;
	thanks.font = [UIFont systemFontOfSize:thanks.font.pointSize - 3];

	[statusbarView addSubview:thanks];
	[_dissidentWindow addSubview:statusbarView];
	[_springboardWindow addSubview:_dissidentWindow];

	[_dissidentWindow setTag:1337];
}

- (void)iconTapped:(id)icon
{
	%orig;

	if ([[[icon valueForKey:@"_icon"] leafIdentifier] isEqualToString:@"dissident"]) {
		[self initializeSettings];
		PushView(_dissidentWindow);
	}
}

%new - (void)clickedStatusbar:(id)sender
{
	PopView(_dissidentWindow);
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"Hei. It seems that you didn't purchase Dissident via Cydia. Either you are testing this tweak before buying it or you pirated it. I didn't want to implement DRM since DRM is not cool, so I am displaying ads on the bottom of the Dissident Settings app. If you can't / don't want to buy this tweak, you could at least support me with clicking on an ad.\nHave a good one. :)" delegate:self cancelButtonTitle:@"Alrighty" otherButtonTitles:nil];
	[alert show];
}

%new - (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
	[self initializeSettings];
	PushView(_dissidentWindow);
}

%end

%subclass DissidentIcon : SBLeafIcon

- (BOOL)launchEnabled
{
	return YES;
}

- (NSString *)displayName
{
	return @"Dissident";
}

- (NSString *)displayNameForLocation:(int)arg1
{
    return @"Dissident";
}

- (id)generateIconImage:(int)flag
{
	UIImage *iconImage = [UIImage imageWithContentsOfFile:@"/Library/Application Support/Dissident/Icon.png"];
	return [iconImage _applicationIconImageForFormat:2 precomposed:NO];
}

%end

%hook SBUIController

- (void)finishLaunching
{
	%orig;

	SBLeafIcon *dissidentSettings = [[objc_getClass("DissidentIcon") alloc] initWithLeafIdentifier:@"dissident" applicationBundleID:nil];
	SBIconController *iconController = [objc_getClass("SBIconController") sharedInstance];
	SBIconModel *iconModel = [iconController valueForKey:@"_iconModel"];
	[iconModel addIcon:dissidentSettings];
	[iconController addNewIconToDesignatedLocation:dissidentSettings animate:NO scrollToList:NO saveIconState:YES];

	for (id object in [[[objc_getClass("FBSceneManager") sharedInstance] valueForKey:@"_displayToRootWindow"] allObjects]) {
		if ([object isKindOfClass:objc_getClass("FBWindow")]) {
			_springboardWindow = (UIWindow *)object;
		}
	}
}

- (BOOL)clickedMenuButton
{
	if ([_dissidentWindow superview]) {
		PopView(_dissidentWindow);

		return YES;
	}

	return %orig;
}

%end

%hook SBLockScreenManager

- (void)_setUILocked:(BOOL)locked
{
	if (locked && _dissidentWindow && [_dissidentWindow superview]) {
		PopView(_dissidentWindow);
	}

	%orig;
}

%end

%ctor {
	@autoreleasepool {
		[[objc_getClass("DissidentSM") sharedInstance] isPurchased];
	}
}
