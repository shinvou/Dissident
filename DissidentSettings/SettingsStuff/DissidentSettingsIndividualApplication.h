#import <UIKit/UIKit.h>

#import "../../Dissident.h"

@interface DissidentSettingsIndividualApplication : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSIndexPath *selectedIndexPath;
@property (nonatomic, strong) NSString *identifier;
@property (nonatomic, strong) UISwitch *preventTerminationSwitch;
@property (nonatomic, strong) UISwitch *automaticLaunchSwitch;
@property (nonatomic, strong) UISwitch *automaticRelaunchSwitch;

- (id)initWithIdentifier:(NSString *)identifier;

@end
