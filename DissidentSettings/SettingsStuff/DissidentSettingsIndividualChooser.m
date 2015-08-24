#import "DissidentSettingsIndividualChooser.h"

static NSString *cellIdentifier = @"dissidentSettingsIndividualChooser";

@implementation DissidentSettingsIndividualChooser

- (id)init
{
  if (self = [super init]) {
    int adSubstraction = [[objc_getClass("DissidentSM") sharedInstance] isPurchased] ? 0 : 50;
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight - 20 - adSubstraction) style:UITableViewStyleGrouped];
    _tableView.delegate = self;
    _tableView.dataSource = self;

    _dataSource = [[ALApplicationTableDataSource alloc] init];
    _dataSource.tableView = _tableView;
    _dataSource.sectionDescriptors = [ALApplicationTableDataSource standardSectionDescriptors];

    [[self view] addSubview:_tableView];

    if (adSubstraction == 50) {
      UIView *adBackground = [[UIView alloc] initWithFrame:CGRectMake(0, _tableView.frame.size.height, kScreenWidth, 50)];
    	adBackground.backgroundColor = UIColorRGB(74, 74, 74);
      [[self view] addSubview:adBackground];
    }

    [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:cellIdentifier];
  }

  return self;
}

- (void)viewDidLoad
{
  [super viewDidLoad];

  [self setTitle:@"Choose Application"];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
  return [_dataSource numberOfSectionsInTableView:tableView];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
  return [_dataSource tableView:tableView titleForHeaderInSection:section];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  return [_dataSource tableView:tableView numberOfRowsInSection:section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  UITableViewCell *cell = [_dataSource tableView:tableView cellForRowAtIndexPath:indexPath];
  cell.imageView.image = [[ALApplicationList sharedApplicationList] iconOfSize:29 forDisplayIdentifier:[_dataSource displayIdentifierForIndexPath:indexPath]];

  return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  [[objc_getClass("DissidentSM") sharedInstance] setBackgroundMode:DissidentMethodNative forIdentifier:[_dataSource displayIdentifierForIndexPath:indexPath]];

  [tableView deselectRowAtIndexPath:indexPath animated:YES];

  [self.navigationController popViewControllerAnimated:YES];
}

@end
