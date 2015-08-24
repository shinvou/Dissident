#import <UIKit/UIKit.h>

#import "../../Dissident.h"

@interface DissidentSettingsOtherIcon : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UISwitch *enabled;

@end
