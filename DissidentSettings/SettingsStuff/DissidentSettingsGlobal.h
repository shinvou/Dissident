#import <UIKit/UIKit.h>

#import "../../Dissident.h"

@interface DissidentSettingsGlobal : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSIndexPath *selectedIndexPath;
@property (nonatomic, strong) UISwitch *preventTerminationSwitch;

@end
