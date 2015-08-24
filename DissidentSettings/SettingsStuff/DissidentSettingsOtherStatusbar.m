#import "DissidentSettingsOtherStatusbar.h"

static NSString *cellIdentifier = @"dissidentSettingsOtherStatusbar";

@implementation DissidentSettingsOtherStatusbar

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

  [self setTitle:@"Statusbar icon"];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
  return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  if (section == 0) {
    return 1;
  }

  return 5;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
  if (section == 0) {
    return @"";
  }

  return @"Indicate following modes";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];

  if (cell == nil) {
      cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
  }

  if (indexPath.section == 0) {
    BOOL indicateBackgroundingIcon = [[objc_getClass("DissidentSM") sharedInstance] statusbarIconIsEnabled];

    _enabled = [[UISwitch alloc] initWithFrame:CGRectZero];
    [_enabled setOn:indicateBackgroundingIcon animated:NO];
    [_enabled addTarget:self action:@selector(enabledSwitchChanged:) forControlEvents:UIControlEventValueChanged];
    cell.accessoryView = _enabled;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;

    cell.textLabel.text = @"Enabled";
  } else {
    if (indexPath.row == 0) {
      cell.textLabel.text = @"Off";
    } else if (indexPath.row == 1) {
      cell.textLabel.text = @"Fast Freeze";
    } else if (indexPath.row == 2) {
      cell.textLabel.text = @"Native";
    } else if (indexPath.row == 3) {
      cell.textLabel.text = @"Unlimited Native";
    } else if (indexPath.row == 4) {
      cell.textLabel.text = @"Foreground";
    }

    if ([[objc_getClass("DissidentSM") sharedInstance] statusbarIconIsEnabledForBackgroundMode:cell.textLabel.text]) {
      cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
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

    [[objc_getClass("DissidentSM") sharedInstance] setStatusbarIconEnabled:!cellHasCheckmark forBackgroundMode:cell.textLabel.text];
  }
}

- (void)enabledSwitchChanged:(id)sender
{
  UISwitch *enabledSwitch = sender;
  [[objc_getClass("DissidentSM") sharedInstance] setStatusbarIconEnabled:enabledSwitch.on];

  [enabledSwitch setOn:enabledSwitch.on animated:YES];
}

@end
