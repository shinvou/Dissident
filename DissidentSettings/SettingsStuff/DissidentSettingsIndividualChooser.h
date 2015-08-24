#import <UIKit/UIKit.h>

#import "../../Dissident.h"

@interface DissidentSettingsIndividualChooser : UIViewController <UITableViewDataSource, UITableViewDelegate> {
  ALApplicationTableDataSource *_dataSource;
}

@property (nonatomic, strong) UITableView *tableView;

@end
