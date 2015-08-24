#import "DissidentSettingsOther.h"

static NSString *cellIdentifier = @"dissidentSettingsOther";

@implementation DissidentSettingsOther

- (id)init
{
  if (self = [super init]) {
    int adSubstraction = [[objc_getClass("DissidentSM") sharedInstance] isPurchased] ? 0 : 50;
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight - 20 - adSubstraction) style:UITableViewStyleGrouped];
    _tableView.delegate = self;
    _tableView.dataSource = self;

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

  [self setTitle:@"Other settings"];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
  return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  return 2;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
  if (section == 0) {
    return @"VISUAL INDICATION";
  }

  return @"ACTIVATOR";
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
  if (section == 0) {
    if (![[objc_getClass("DissidentSM") sharedInstance] isStatusbarSupported]) {
      return @"Please install libstatusbar in Cydia to use statusbar indication.";
    }
  } else if (section == 1) {
    if ([[objc_getClass("DissidentSM") sharedInstance] isActivatorSupported]) {
      return @"Assign activator events to actions.";
    } else {
      return @"Please install Activator in Cydia to use this feature.";
    }
  }

  return @"";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];

  if (cell == nil) {
      cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
  }

  cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

  if (indexPath.section == 0) {
    if (indexPath.row == 0) {
      cell.textLabel.text = @"Icon badge";
    } else {
      cell.textLabel.text = @"Statusbar icon";

      if (![[objc_getClass("DissidentSM") sharedInstance] isStatusbarSupported]) {
        cell.textLabel.enabled = NO;
        cell.userInteractionEnabled = NO;
      }
    }
  } else {
    if (indexPath.row == 0) {
      cell.textLabel.text = @"Toggle Foregrounding Temporary";

      if (![[objc_getClass("DissidentSM") sharedInstance] isActivatorSupported]) {
        cell.textLabel.enabled = NO;
        cell.userInteractionEnabled = NO;
      }
    } else {
      cell.textLabel.text = @"Toggle Foregrounding Permanent";

      if (![[objc_getClass("DissidentSM") sharedInstance] isActivatorSupported]) {
        cell.textLabel.enabled = NO;
        cell.userInteractionEnabled = NO;
      }
    }
  }

  return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  [tableView deselectRowAtIndexPath:indexPath animated:YES];

  if (indexPath.section == 0) {
    if (indexPath.row == 0) {
      DissidentSettingsOtherIcon *dissidentSettingsOtherIcon = [[DissidentSettingsOtherIcon alloc] init];
      [self.navigationController pushViewController:dissidentSettingsOtherIcon animated:YES];
    } else {
      DissidentSettingsOtherStatusbar *dissidentSettingsOtherStatusbar = [[DissidentSettingsOtherStatusbar alloc] init];
      [self.navigationController pushViewController:dissidentSettingsOtherStatusbar animated:YES];
    }
  } else {
    if (indexPath.row == 0) {
      UIViewController *viewController = [[objc_getClass("LAListenerSettingsViewController") alloc] init];
      [(LAListenerSettingsViewController *)viewController setListenerName:@"com.shinvou.dissident.toggleforcedbackgroundingtmp"];
      [self.navigationController pushViewController:viewController animated:YES];
    } else {
      UIViewController *viewController = [[objc_getClass("LAListenerSettingsViewController") alloc] init];
      [(LAListenerSettingsViewController *)viewController setListenerName:@"com.shinvou.dissident.toggleforcedbackgrounding"];
      [self.navigationController pushViewController:viewController animated:YES];
    }
  }
}

@end
