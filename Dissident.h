#include <spawn.h>

#import <substrate.h>

#import <LSStatusBarItem.h>
#import <AppList/AppList.h>
#import <libactivator/libactivator.h>

#import <Foundation/NSDistributedNotificationCenter.h>

#import <GoogleMobileAds/GADBannerView.h>

#import "./DissidentSettings/SettingsStuff/DissidentWindow.h"
#import "./DissidentSettings/SettingsStuff/DissidentSettings.h"
#import "./DissidentSettings/SettingsStuff/DissidentSettingsGlobal.h"
#import "./DissidentSettings/SettingsStuff/DissidentSettingsIndividual.h"
#import "./DissidentSettings/SettingsStuff/DissidentSettingsOther.h"
#import "./DissidentSettings/SettingsStuff/DissidentSettingsIndividualApplication.h"
#import "./DissidentSettings/SettingsStuff/DissidentSettingsIndividualChooser.h"
#import "./DissidentSettings/SettingsStuff/DissidentSettingsOtherIcon.h"
#import "./DissidentSettings/SettingsStuff/DissidentSettingsOtherStatusbar.h"
#import "./DissidentSettings/SettingsStuff/DissidentUITableViewCell.h"

//#define LOGGING_ENABLED

#ifdef LOGGING_ENABLED
  #define log(format, ...) NSLog(@"[Dissident] %@", [NSString stringWithFormat:format, ## __VA_ARGS__])
#else
  #define log(format, ...)
#endif

#define kScreenWidth [[UIScreen mainScreen] bounds].size.width
#define kScreenHeight [[UIScreen mainScreen] bounds].size.height

#define settingsPath @"/var/mobile/Library/Preferences/com.shinvou.dissident.plist"
#define UIColorRGB(r, g, b) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1.0]

#define validUser @"http://shinvou.org/dissident/validUser.php?product=org.thebigboss.dissident&udid="
#define statisticsUser @"http://shinvou.org/dissident/abc.php?uuid="

typedef enum {
    DissidentMethodOff = 0,
    DissidentMethodFastFreeze,
    DissidentMethodNative,
    DissidentMethodUnlimitedNative,
    DissidentMethodForeground,
    DissidentMethodErrorOccured
} DissidentMethod;

@interface UIApplication (libstatusbar)
- (void)addStatusBarImageNamed:(NSString *)name removeOnExit:(BOOL)remove;
- (void)addStatusBarImageNamed:(NSString *)name;
- (void)removeStatusBarImageNamed:(NSString *)name;
@end

@interface BKNewProcess : NSObject
- (NSString *)bundleIdentifier;
@end

@interface BKSProcess : NSObject
- (void)_handleExpirationWarning:(id)xpcdictionary;
@end

@interface FBProcessExecutionContext : NSObject
@property(retain, nonatomic) NSDictionary *environment; // @synthesize environment=_environment;
@end

@interface FBApplicationProcess : NSObject {
	BKSProcess *_bksProcess;
}
@property(retain, nonatomic) FBProcessExecutionContext *executionContext; // @dynamic executionContext;
- (id)bundleIdentifier;
- (void)stop;
- (void)setPendingExit:(BOOL)arg1;
- (void)_queue_doGracefulKillWithCompletion:(id)arg1 withWatchdog:(BOOL)arg2;
@end

@interface FBUIApplicationResignActiveManager
- (void)_sendResumeActiveForReason:(int)arg1 toProcess:(FBApplicationProcess *)applicationProcess;
- (void)_sendResignActiveForReason:(int)arg1 toProcess:(FBApplicationProcess *)applicationProcess;
- (void)sendManualSuspendToProcess:(FBApplicationProcess *)applicationProcess;
@end

@interface AADeviceInfo : NSObject
+ (id)udid;
@end

@interface SBUIController
+ (id)sharedInstanceIfExists;
- (BOOL)clickedMenuButton;
@end

@interface UIImage (Private)
- (UIImage *)_applicationIconImageForFormat:(int)format precomposed:(BOOL)precomposed;
@end

@interface SBIconViewMap
+ (id)homescreenMap;
- (id)mappedIconViewForIcon:(id)icon;
@end

@interface SBIcon
-(id)applicationBundleID;
-(void)_notifyAccessoriesDidUpdate;
- (id)leafIdentifier;
@end

@interface SBIconView : UIView
@property(retain, nonatomic) SBIcon* icon;
-(UIView *)_iconImageView;
+(CGSize)defaultVisibleIconImageSize;
+(CGSize)defaultIconImageSize;
+(CGSize)defaultIconSize;
-(CGRect)iconImageFrame;
@end

@interface SBLeafIcon : SBIcon {
  NSString* _leafIdentifier;
}
-(id)leafIdentifier;
-(id)initWithLeafIdentifier:(id)leafIdentifier applicationBundleID:(id)anId;
@end

@interface SBIconController : NSObject <UIAlertViewDelegate>
+ (id)sharedInstance;
- (id)model;
- (void)iconTapped:(id)icon;
- (void)icon:(id)icon touchEnded:(BOOL)ended;
- (void)addNewIconToDesignatedLocation:(id)designatedLocation animate:(BOOL)animate scrollToList:(BOOL)list saveIconState:(BOOL)state;
- (void)clearHighlightedIcon;
- (void)initializeSettings;
@end

@interface SBIconModel : NSObject
- (void)addIcon:(id)icon;
-(id)expectedIconForDisplayIdentifier:(id)displayIdentifier;
@end

@interface SBAppSwitcherIconView
@property(retain, nonatomic) SBIcon* icon;
-(void)setHighlighted:(BOOL)highlighted;
@end

@interface BKSProcessAssertion : NSObject
@property(readonly) bool valid;
- (id)initWithBundleIdentifier:(id)arg1 flags:(unsigned int)arg2 reason:(unsigned int)arg3 name:(id)arg4 withHandler:(id)arg5;
@end

@protocol FBSceneClient <NSObject>
- (void)host:(id)arg1 didUpdateSettings:(id)arg2 withDiff:(id)arg3 transitionContext:(id)arg4 completion:(id)arg5;
- (void)toggleTemporaryEnabledForIdentifier:(NSString *)identifier;
@end

@interface FBSSceneClientSettingsDiff
+ (id)diffFromSettings:(id)arg1 toSettings:(id)arg2;
@end

@interface FBSSceneSettingsDiff : NSObject
+ (id)diffFromSettings:(id)arg1 toSettings:(id)arg2;
@end

@interface FBSSceneSettings : NSObject
- (BOOL)isBackgrounded;
- (void)setBackgrounded:(char)bg;
@end

@interface FBUIApplicationWorkspaceScene : NSObject
- (void)host:(id)arg1 didUpdateSettings:(FBSSceneSettings *)sceneSettings withDiff:(id)arg3 transitionContext:(id)arg4 completion:(id)arg5;
- (void)toggleTemporaryEnabledForIdentifier:(NSString *)identifier;
@end

@protocol FBSceneClientProvider <NSObject>
- (void)endTransaction;
- (void)beginTransaction;
@end

@interface FBScene : NSObject
@property(readonly, retain, nonatomic) id <FBSceneClient> client;
@property(readonly, retain, nonatomic) id <FBSceneClientProvider> clientProvider;
@property(readonly, retain, nonatomic) FBSSceneSettings *settings;
@end

@interface FBSceneManager : NSObject
- (FBScene *)sceneWithIdentifier:(id)arg1;
@end

@interface SBApplicationController
- (id)applicationWithBundleIdentifier:(id)sss;
@end

@interface SBApplication : NSObject {
	FBApplicationProcess* _process;
}
- (id)bundleIdentifier;
- (BOOL)isRunning;
- (void)clearDeactivationSettings;
- (void)didExitWithType:(int)type terminationReason:(int)reason;
@end

@interface SpringBoard : UIApplication
@property (nonatomic, retain, readonly) SBApplication *_accessibilityFrontMostApplication;
@end

@interface UIApplication (Private)
- (id)displayIdentifier;
- (void)_setSuspended:(BOOL)arg1;
- (void)launchApplicationWithIdentifier:(id)identifier suspended:(int)ccc;
@end

@interface DissidentActivatorInitializer : NSObject
+ (id)sharedInstance;
- (void)initializeActivatorActions;
@end

@interface DissidentSM : NSObject
+ (id)sharedInstance;
- (BOOL)isActivatorSupported;
- (BOOL)isStatusbarSupported;
- (BOOL)globalHasPreventTerminationSettings;
- (BOOL)identifierHasPreventTerminationSettings:(NSString *)identifier;
- (int)globalBackgroundMode;
- (int)backgroundModeForIdentifier:(NSString *)identifier;
- (BOOL)identifierHasAutomaticLaunchSettings:(NSString *)identifier;
- (BOOL)identifierHasAutomaticRelaunchSettings:(NSString *)identifier;
- (BOOL)iconBadgeIsEnabled;
- (BOOL)iconBadgeIsEnabledForBackgroundMode:(NSString *)backgroundMode;
- (BOOL)statusbarIconIsEnabled;
- (BOOL)statusbarIconIsEnabledForBackgroundMode:(NSString *)backgroundMode;
- (void)setGlobalPreventTerminationEnabled:(BOOL)enabled;
- (void)setPreventTerminationEnabled:(BOOL)enabled forIdentifier:(NSString *)identifier;
- (void)setGlobalBackgroundMode:(int)backgroundMode;
- (void)setBackgroundMode:(int)backgroundMode forIdentifier:(NSString *)identifier;
- (void)removeIdentifier:(NSString *)identifier forBackgroundMode:(int)backgroundMode;
- (void)setAutomaticLaunchEnabled:(BOOL)enabled forIdentifier:(NSString *)identifier;
- (void)setAutomaticRelaunchEnabled:(BOOL)enabled forIdentifier:(NSString *)identifier;
- (NSArray *)identifiersWithBackgroundModeSelected;
- (void)setBackgroundModeSelected:(BOOL)selected forIdentifier:(NSString *)identifier;
- (void)setIconBadgeEnabled:(BOOL)enabled;
- (void)setIconBadgeEnabled:(BOOL)enabled forBackgroundMode:(NSString *)backgroundMode;
- (void)setStatusbarIconEnabled:(BOOL)enabled;
- (void)setStatusbarIconEnabled:(BOOL)enabled forBackgroundMode:(NSString *)backgroundMode;
- (void)firstRun;
- (BOOL)isPurchased;
@end


@interface DissidentHelper : NSObject
@property (nonatomic, strong) NSMutableDictionary *assertions;
+ (id)sharedInstance;
- (void)addAssertionForIdentifier:(NSString *)identifier;
- (void)removeAssertionForIdentifier:(NSString *)identifier;
- (void)startBackgroundingForIdentifier:(NSString *)identifier;
- (void)stopBackgroundingForIdentifier:(NSString *)identifier;
- (void)refreshBackgroundingEnabled:(BOOL)enabled forIdentifier:(NSString *)identifier;
@end

typedef struct {
        unsigned int deactivatingReasonFlags : 11;
        unsigned int isSuspended : 1;
        unsigned int isSuspendedEventsOnly : 1;
        unsigned int isLaunchedSuspended : 1;
        unsigned int calledNonSuspendedLaunchDelegate : 1;
        unsigned int calledSuspendedLaunchDelegate : 1;
        unsigned int isHandlingURL : 1;
        unsigned int statusBarShowsProgress : 1;
        unsigned int statusBarHidden : 1;
        unsigned int statusBarHiddenDefault : 1;
        unsigned int statusBarHiddenVerticallyCompact : 1;
        unsigned int blockInteractionEvents : 4;
        unsigned int receivesMemoryWarnings : 1;
        unsigned int showingProgress : 1;
        unsigned int receivesPowerMessages : 1;
        unsigned int launchEventReceived : 1;
        unsigned int activateEventReceived : 1;
        unsigned int systemIsAnimatingApplicationLifecycleEvent : 1;
        unsigned int isActivating : 1;
        unsigned int isSuspendedUnderLock : 1;
        unsigned int shouldExitAfterSendSuspend : 1;
        unsigned int terminating : 1;
        unsigned int isHandlingShortCutURL : 1;
        unsigned int idleTimerDisabled : 1;
        unsigned int deviceOrientation : 3;
        unsigned int delegateShouldBeReleasedUponSet : 1;
        unsigned int delegateHandleOpenURL : 1;
        unsigned int delegateOpenURL : 1;
        unsigned int delegateDidReceiveMemoryWarning : 1;
        unsigned int delegateWillTerminate : 1;
        unsigned int delegateSignificantTimeChange : 1;
        unsigned int delegateWillChangeInterfaceOrientation : 1;
        unsigned int delegateDidChangeInterfaceOrientation : 1;
        unsigned int delegateWillChangeStatusBarFrame : 1;
        unsigned int delegateDidChangeStatusBarFrame : 1;
        unsigned int delegateDeviceAccelerated : 1;
        unsigned int delegateDeviceChangedOrientation : 1;
        unsigned int delegateDidBecomeActive : 1;
        unsigned int delegateWillResignActive : 1;
        unsigned int delegateDidEnterBackground : 1;
        unsigned int delegateDidEnterBackgroundWasSent : 1;
        unsigned int delegateWillEnterForeground : 1;
        unsigned int delegateWillSuspend : 1;
        unsigned int delegateDidResume : 1;
        unsigned int delegateSupportsStateRestoration : 1;
        unsigned int delegateSupportedInterfaceOrientations : 1;
        unsigned int delegateHandleSiriTask : 1;
        unsigned int delegateSupportsWatchKitRequests : 1;
        unsigned int userDefaultsSyncDisabled : 1;
        unsigned int headsetButtonClickCount : 4;
        unsigned int isHeadsetButtonDown : 1;
        unsigned int isFastForwardActive : 1;
        unsigned int isRewindActive : 1;
        unsigned int shakeToEdit : 1;
        unsigned int zoomInClassicMode : 1;
        unsigned int ignoreHeadsetClicks : 1;
        unsigned int touchRotationDisabled : 1;
        unsigned int taskSuspendingUnsupported : 1;
        unsigned int taskSuspendingOnLockUnsupported : 1;
        unsigned int isUnitTests : 1;
        unsigned int requiresHighResolution : 1;
        unsigned int singleUseLaunchOrientation : 3;
        unsigned int defaultInterfaceOrientation : 3;
        unsigned int supportedInterfaceOrientationsMask : 5;
        unsigned int delegateWantsNextResponder : 1;
        unsigned int isRunningInApplicationSwitcher : 1;
        unsigned int isSendingEventForProgrammaticTouchCancellation : 1;
        unsigned int delegateWantsStatusBarTouchesEnded : 1;
        unsigned int interfaceLayoutDirectionIsValid : 1;
        unsigned int interfaceLayoutDirection : 3;
        unsigned int restorationExtended : 1;
        unsigned int normalRestorationInProgress : 1;
        unsigned int normalRestorationCompleted : 1;
        unsigned int isDelayingTintViewChange : 1;
        unsigned int isUpdatingTintViewColor : 1;
        unsigned int isHandlingMemoryWarning : 1;
        unsigned int forceStatusBarTintColorChanges : 1;
        unsigned int disableLegacyAutorotation : 1;
        unsigned int isFakingForegroundTransitionForBackgroundFetch : 1;
        unsigned int couldNotRestoreStateWhenLocked : 1;
        unsigned int disableStyleOverrides : 1;
        unsigned int legibilityAccessibilitySettingEnabled : 1;
        unsigned int viewControllerBasedStatusBarAppearance : 1;
        unsigned int fakingRequiresHighResolution : 1;
        unsigned int isStatusBarFading : 1;
        unsigned int systemWindowsSecure : 1;
} UIApplicationFlags8x;
