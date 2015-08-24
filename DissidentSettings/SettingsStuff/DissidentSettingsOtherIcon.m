#import "DissidentSettingsOtherIcon.h"

static NSString *cellIdentifier = @"dissidentSettingsOtherIcon";

@implementation DissidentSettingsOtherIcon

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

  [self setTitle:@"Icon badge"];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
  return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  if (section == 1) {
    return 4;
  }

  return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
  if (section == 1) {
    return @"Indicate following modes";
  }

  return @"";
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
  if (section == 0) {
    return @"If enabled, badges will be added to app icons for the modes chosen below.\n\nWHITE BADGE: Fast Freeze\nLIGHT GRAY BADGE: Native\nDARK GRAY BADGE: Unlimited Native\nBLACK BADGE: Foreground";
  } else if (section == 1) {
    return @"Please respring if you change these settings.";
  }

  return @"";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];

  if (cell == nil) {
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
  }

  if (indexPath.section == 0) {
    BOOL indicateBackgroundingIcon = [[objc_getClass("DissidentSM") sharedInstance] iconBadgeIsEnabled];

    _enabled = [[UISwitch alloc] initWithFrame:CGRectZero];
    [_enabled setOn:indicateBackgroundingIcon animated:NO];
    [_enabled addTarget:self action:@selector(enabledSwitchChanged:) forControlEvents:UIControlEventValueChanged];
    cell.accessoryView = _enabled;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;

    cell.textLabel.text = @"Enabled";
  } else if (indexPath.section == 1) {
    if (indexPath.row == 0) {
      cell.textLabel.text = @"Fast Freeze";
    } else if (indexPath.row == 1) {
      cell.textLabel.text = @"Native";
    } else if (indexPath.row == 2) {
      cell.textLabel.text = @"Unlimited Native";
    } else {
      cell.textLabel.text = @"Foreground";
    }

    if ([[objc_getClass("DissidentSM") sharedInstance] iconBadgeIsEnabledForBackgroundMode:cell.textLabel.text]) {
      cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
  } else {
    cell.textLabel.text = @"Respring ...";
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    cell.textLabel.textColor = [button titleColorForState:UIControlStateNormal];
  }

  return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  [tableView deselectRowAtIndexPath:indexPath animated:YES];

  UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];

  if (indexPath.section == 1) {
    BOOL cellHasCheckmark = cell.accessoryType == UITableViewCellAccessoryCheckmark;
    cell.accessoryType = cellHasCheckmark ? UITableViewCellAccessoryNone : UITableViewCellAccessoryCheckmark;

    [[objc_getClass("DissidentSM") sharedInstance] setIconBadgeEnabled:!cellHasCheckmark forBackgroundMode:cell.textLabel.text];
  } else if (indexPath.section == 2) {
    const char *argv[] = {"killall", "-9", "backboardd", NULL};
    posix_spawn(NULL, "/usr/bin/killall", NULL, NULL, (char **)argv, NULL);
  }
}

- (void)enabledSwitchChanged:(id)sender
{
  UISwitch *enabledSwitch = sender;
  [[objc_getClass("DissidentSM") sharedInstance] setIconBadgeEnabled:enabledSwitch.on];

  [enabledSwitch setOn:enabledSwitch.on animated:YES];
}

@end
